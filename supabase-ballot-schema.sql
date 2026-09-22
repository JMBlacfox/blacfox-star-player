-- Schema for the Blacfox Star Player ballot app.
-- Three tables back the shared state: signups, votes, and a single voting_status row.
-- Recreating them removes stale/incompatible versions created during setup; run this before using the ballot app.
drop table if exists public.signups cascade;
drop table if exists public.votes cascade;
drop table if exists public.voting_status cascade;

create table public.signups (
  name text primary key,
  created_at timestamptz not null default now()
);

create table public.votes (
  voter text primary key,
  candidate text not null,
  created_at timestamptz not null default now()
);

create table public.voting_status (
  id integer primary key default 1 check (id = 1),
  status text not null default 'setup' check (status in ('setup', 'open', 'closed', 'tie', 'published')),
  closed_at bigint,
  tie_names jsonb not null default '[]'::jsonb
);

alter table public.signups enable row level security;
alter table public.votes enable row level security;
alter table public.voting_status enable row level security;

drop policy if exists "Allow public signups access" on public.signups;
create policy "Allow public signups access"
  on public.signups for all
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "Allow public votes access" on public.votes;
create policy "Allow public votes access"
  on public.votes for all
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "Allow public voting_status access" on public.voting_status;
create policy "Allow public voting_status access"
  on public.voting_status for all
  to anon, authenticated
  using (id = 1)
  with check (id = 1);

insert into public.voting_status (id)
values (1)
on conflict (id) do nothing;

update public.voting_status
set status = 'setup', closed_at = null, tie_names = '[]'::jsonb
where id = 1;
