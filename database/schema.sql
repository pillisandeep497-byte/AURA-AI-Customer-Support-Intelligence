create extension if not exists vector with schema extensions;

create table if not exists public.documents (
    id bigserial primary key,
    source_id text not null,
    source_type text not null default 'policy',
    title text not null,
    content text not null,
    chunk_index integer not null default 0,
    version text not null default '1',
    product text,
    metadata jsonb not null default '{}'::jsonb,
    embedding extensions.vector(384),
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    unique (source_id, version, chunk_index)
);

create index if not exists documents_embedding_idx
on public.documents using hnsw (embedding vector_cosine_ops);

create table if not exists public.support_tickets (
    id bigserial primary key,
    external_ticket_id text unique,
    customer_ref text,
    product text not null,
    category text not null,
    subject text not null,
    description text not null,
    status text not null default 'open',
    priority text not null default 'normal',
    resolution text,
    created_at timestamptz not null default now(),
    resolved_at timestamptz
);

create index if not exists tickets_created_at_idx
on public.support_tickets (created_at);
create index if not exists tickets_product_category_idx
on public.support_tickets (product, category);

create table if not exists public.ai_audit_logs (
    id bigserial primary key,
    request_id uuid not null,
    question text not null,
    answer text,
    sources jsonb not null default '[]'::jsonb,
    verification_status text,
    model text,
    created_at timestamptz not null default now()
);

create table if not exists public.action_proposals (
    id bigserial primary key,
    request_id uuid not null,
    action_type text not null,
    action_payload jsonb not null default '{}'::jsonb,
    status text not null default 'pending'
      check (status in ('pending', 'approved', 'rejected', 'executed', 'failed')),
    reviewer text,
    reviewed_at timestamptz,
    execution_result jsonb,
    created_at timestamptz not null default now()
);

create or replace function public.match_documents(
    query_embedding extensions.vector(384),
    match_count integer default 5,
    source_filter text default null
)
returns table (
    id bigint,
    source_id text,
    source_type text,
    title text,
    content text,
    chunk_index integer,
    version text,
    similarity double precision
)
language sql
stable
as $$
    select d.id, d.source_id, d.source_type, d.title, d.content,
           d.chunk_index, d.version,
           1 - (d.embedding <=> query_embedding) as similarity
    from public.documents d
    where d.is_active = true
      and d.embedding is not null
      and (source_filter is null or d.source_type = source_filter)
    order by d.embedding <=> query_embedding
    limit least(greatest(match_count, 1), 20);
$$;

create or replace function public.compare_ticket_volume(
    start_date timestamptz,
    end_date timestamptz,
    product_filter text default null
)
returns table (
    category text,
    previous_count bigint,
    current_count bigint,
    change_count bigint
)
language sql
stable
as $$
    with periods as (
        select
            t.category,
            count(*) filter (
                where t.created_at >= start_date
                  and t.created_at < end_date
            ) as previous_count,
            count(*) filter (
                where t.created_at >= end_date
                  and t.created_at < end_date + (end_date - start_date)
            ) as current_count
        from public.support_tickets t
        where t.created_at >= start_date
          and t.created_at < end_date + (end_date - start_date)
          and (product_filter is null or t.product = product_filter)
        group by t.category
    )
    select category, previous_count, current_count,
           current_count - previous_count as change_count
    from periods
    order by change_count desc;
$$;

-- For production: enable RLS and create explicit policies before exposing tables
-- through the Supabase Data API. Keep privileged keys only in server-side secrets.
