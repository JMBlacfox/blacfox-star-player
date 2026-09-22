-- This table stores one shared ballot. Recreating it removes stale/incompatible
-- versions created during setup; run this before using the ballot app.
drop table if exists public.ballot_state cascade;

create table public.ballot_state (
  id integer primary key default 1 check (id = 1),
  signups jsonb not null default '[]'::jsonb,
  votes jsonb not null default '{}'::jsonb,
  status text not null default 'waiting' check (status in ('waiting', 'open', 'closed', 'published')),
  closed_at bigint,
  updated_at timestamptz not null default now()
);

alter table public.ballot_state enable row level security;

drop policy if exists "Allow public ballot reads" on public.ballot_state;
create policy "Allow public ballot reads"
  on public.ballot_state for select
  to anon, authenticated
  using (true);

drop policy if exists "Allow public ballot writes" on public.ballot_state;
create policy "Allow public ballot writes"
  on public.ballot_state for insert
  to anon, authenticated
  with check (id = 1);

drop policy if exists "Allow public ballot updates" on public.ballot_state;
create policy "Allow public ballot updates"
  on public.ballot_state for update
  to anon, authenticated
  using (id = 1)
  with check (id = 1);

insert into public.ballot_state (id)
values (1)
on conflict (id) do nothing;

update public.ballot_state
set status = 'waiting', closed_at = null
where id = 1;
