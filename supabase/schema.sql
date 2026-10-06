-- Minar Catalogue & Price Manager: run this whole file once in Supabase -> SQL Editor -> New query -> Run
create extension if not exists pgcrypto with schema extensions;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  status text not null default 'pending' check (status in ('pending','approved','locked','kicked','rejected')),
  is_owner boolean not null default false,
  admin_until timestamptz,
  created_at timestamptz not null default now()
);
create table public.brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  created_at timestamptz not null default now()
);
create table public.products (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  model text not null,
  category text not null default '',
  size text not null default '',
  body text not null default '',
  layer text not null default '',
  price numeric not null,
  created_at timestamptz not null default now()
);
create table public.app_settings (key text primary key, value text not null);

-- who is asking? (security definer = can read profiles without recursion)
create function public.app_is_owner() returns boolean language sql security definer set search_path = public stable as
$$ select exists(select 1 from profiles where id = auth.uid() and is_owner and status = 'approved') $$;
create function public.app_is_approved() returns boolean language sql security definer set search_path = public stable as
$$ select exists(select 1 from profiles where id = auth.uid() and status = 'approved') $$;
create function public.app_admin_unlocked() returns boolean language sql security definer set search_path = public stable as
$$ select exists(select 1 from profiles where id = auth.uid() and status = 'approved' and admin_until > now()) $$;

-- every new sign-up gets a profile: the very first account = App Owner (approved), everyone else = pending
create function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
declare first_user boolean;
begin
  select not exists(select 1 from profiles) into first_user;
  insert into profiles(id, email, status, is_owner)
  values (new.id, lower(new.email), case when first_user then 'approved' else 'pending' end, first_user);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

-- row level security
alter table public.profiles enable row level security;
alter table public.brands enable row level security;
alter table public.products enable row level security;
alter table public.app_settings enable row level security;          -- no policy = nobody can read it directly

create policy "read own profile" on public.profiles for select using (id = auth.uid());
create policy "owner reads all profiles" on public.profiles for select using (public.app_is_owner());
create policy "owner updates users" on public.profiles for update
  using (public.app_is_owner() and not is_owner) with check (public.app_is_owner() and not is_owner);
revoke update on public.profiles from anon, authenticated;
grant update (status) on public.profiles to authenticated;           -- owner can only change the status column

create policy "approved users read brands" on public.brands for select using (public.app_is_approved());
create policy "approved users read products" on public.products for select using (public.app_is_approved());
create policy "admin writes brands" on public.brands for all using (public.app_admin_unlocked()) with check (public.app_admin_unlocked());
create policy "admin writes products" on public.products for all using (public.app_admin_unlocked()) with check (public.app_admin_unlocked());

-- admin password (checked on the server). Default: admin123  -> change it from the app right after first login
insert into public.app_settings(key, value) values ('admin_pwd', extensions.crypt('admin123', extensions.gen_salt('bf')));

create function public.unlock_admin(pwd text) returns boolean language plpgsql security definer set search_path = public, extensions as $$
declare h text;
begin
  if not app_is_approved() then return false; end if;
  select value into h from app_settings where key = 'admin_pwd';
  if h is not null and crypt(pwd, h) = h then
    update profiles set admin_until = now() + interval '8 hours' where id = auth.uid();
    return true;
  end if;
  return false;
end $$;

create function public.change_admin_password(old_pwd text, new_pwd text) returns boolean language plpgsql security definer set search_path = public, extensions as $$
declare h text;
begin
  if not app_is_approved() or length(new_pwd) < 4 then return false; end if;
  select value into h from app_settings where key = 'admin_pwd';
  if h is null or crypt(old_pwd, h) <> h then return false; end if;
  update app_settings set value = crypt(new_pwd, gen_salt('bf')) where key = 'admin_pwd';
  return true;
end $$;

-- a removed/rejected user can ask again with the same Gmail
create function public.reapply() returns void language sql security definer set search_path = public as
$$ update profiles set status = 'pending' where id = auth.uid() and status in ('kicked','rejected') $$;
