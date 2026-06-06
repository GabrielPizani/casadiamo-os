# Casa Di Amo OS — Arquitetura do Banco de Dados

**Versão:** 1.0  
**Fase:** Planejamento & Arquitetura  
**Arquiteto:** IA — Arquiteto de Software Sênior SaaS  
**Banco de Dados:** PostgreSQL via Supabase  
**Estratégia Multi-Tenant:** Schema compartilhado com `tenant_id` + Row-Level Security (RLS)

---

## Estratégia Multi-Tenant

O Casa Di Amo OS é uma plataforma **white-label multi-tenant**. Toda empresa cliente (tenant) opera de forma completamente isolada dentro do mesmo banco de dados.

**Estratégia adotada:** Shared Database, Shared Schema com `tenant_id`

- Cada tabela possui uma coluna `tenant_id` (FK para `tenants`)
- Isolamento garantido por Row-Level Security (RLS) do PostgreSQL/Supabase
- Custo eficiente, escalável e compatível com a arquitetura nativa do Supabase
- Permite crescimento de centenas para milhares de tenants sem mudança de infraestrutura

**Regra universal:** Nenhum dado de um tenant pode ser acessado por outro tenant. Toda query de aplicação inclui `tenant_id` implicitamente via RLS.

---

## Visão Geral dos Módulos

| # | Módulo | Responsabilidade |
|---|--------|-----------------|
| 0 | **Core / Foundation** | Tenants, planos, assinaturas, billing |
| 1 | **Auth & Usuários** | Usuários, perfis, papéis, permissões |
| 2 | **Clientes** | Cadastro de clientes, contatos, histórico |
| 3 | **Agendamento** | Serviços, profissionais, horários, consultas |
| 4 | **CRM** | Pipelines, negócios, atividades, funis |
| 5 | **Marketing** | Campanhas, segmentos, templates, métricas |
| 6 | **Automações** | Workflows, gatilhos, ações, logs de execução |
| 7 | **Integrações** | HubSpot, ManyChat, WhatsApp, Google Calendar, Calendly |
| 8 | **Relatórios & Analytics** | Dashboards, métricas, eventos, relatórios salvos |
| 9 | **Configurações** | Configurações por tenant, campos customizados, tags |

---

## Módulo 0 — Core / Foundation

> Infraestrutura da plataforma SaaS. Gerencia os tenants como clientes do sistema.

### Entidades

#### `tenants`
Representa cada empresa/negócio cliente da plataforma (o tenant).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | Identificador único |
| name | TEXT | Nome da empresa |
| slug | TEXT UNIQUE | Identificador de URL (ex: `clinica-bela`) |
| logo_url | TEXT | URL do logotipo (white-label) |
| primary_color | TEXT | Cor primária da marca (white-label) |
| business_type | ENUM | Tipo de negócio (clínica, estética, petshop, consultoria, outro) |
| status | ENUM | active, suspended, cancelled, trial |
| trial_ends_at | TIMESTAMPTZ | Data de fim do período trial |
| timezone | TEXT | Fuso horário padrão (ex: America/Sao_Paulo) |
| locale | TEXT | Idioma padrão (ex: pt-BR) |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

#### `plans`
Planos de assinatura disponíveis na plataforma.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | Identificador único |
| name | TEXT | Nome do plano (Starter, Pro, Enterprise) |
| description | TEXT | Descrição do plano |
| price_monthly | NUMERIC | Preço mensal |
| price_annual | NUMERIC | Preço anual |
| max_users | INTEGER | Limite de usuários (null = ilimitado) |
| max_customers | INTEGER | Limite de clientes cadastrados |
| max_appointments_month | INTEGER | Limite de agendamentos por mês |
| features | JSONB | Lista de features habilitadas |
| is_active | BOOLEAN | Plano disponível para novos clientes |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `subscriptions`
Assinatura ativa de cada tenant.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | Identificador único |
| tenant_id | UUID FK → tenants | Tenant assinante |
| plan_id | UUID FK → plans | Plano contratado |
| status | ENUM | active, past_due, cancelled, trialing |
| current_period_start | TIMESTAMPTZ | Início do período atual |
| current_period_end | TIMESTAMPTZ | Fim do período atual |
| cancelled_at | TIMESTAMPTZ | Data de cancelamento |
| payment_provider | TEXT | Stripe, Hotmart, etc. |
| external_subscription_id | TEXT | ID no provedor de pagamento |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `invoices`
Histórico de cobranças por tenant.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| subscription_id | UUID FK → subscriptions | |
| amount | NUMERIC | Valor cobrado |
| status | ENUM | paid, pending, failed, refunded |
| due_date | DATE | Vencimento |
| paid_at | TIMESTAMPTZ | Data de pagamento |
| invoice_url | TEXT | URL do boleto/NF |
| external_invoice_id | TEXT | ID no provedor de pagamento |
| created_at | TIMESTAMPTZ | |

---

## Módulo 1 — Auth & Usuários

> Gerencia quem pode acessar o sistema e o que pode fazer dentro de cada tenant.

### Entidades

#### `profiles`
Extensão do usuário de autenticação do Supabase Auth (`auth.users`). Dados de perfil do operador da plataforma.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK FK → auth.users | Mesmo ID do Supabase Auth |
| full_name | TEXT | Nome completo |
| avatar_url | TEXT | Foto de perfil |
| phone | TEXT | Telefone pessoal |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `tenant_users`
Relacionamento entre usuários e tenants. Um usuário pode pertencer a múltiplos tenants com papéis diferentes.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | Tenant de contexto |
| user_id | UUID FK → profiles | Usuário |
| role_id | UUID FK → roles | Papel do usuário neste tenant |
| status | ENUM | active, invited, suspended |
| invited_at | TIMESTAMPTZ | Data do convite |
| joined_at | TIMESTAMPTZ | Data de aceite |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `roles`
Papéis disponíveis dentro de um tenant.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | Papel pertence ao tenant (ou null = papel global do sistema) |
| name | TEXT | owner, admin, manager, staff, viewer |
| description | TEXT | Descrição do papel |
| is_system | BOOLEAN | Papel padrão do sistema (não editável) |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `permissions`
Permissões granulares do sistema.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| module | TEXT | customers, scheduling, crm, marketing, etc. |
| action | TEXT | create, read, update, delete, export |
| description | TEXT | Descrição legível da permissão |

#### `role_permissions`
Permissões atribuídas a cada papel.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| role_id | UUID FK → roles | |
| permission_id | UUID FK → permissions | |

---

## Módulo 2 — Clientes

> Cadastro central de clientes dos tenants. Base para CRM, agendamento e marketing.

### Entidades

#### `customers`
Cliente final do negócio (paciente, animal de estimação, cliente de consultoria, etc.).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| full_name | TEXT | Nome completo |
| document | TEXT | CPF/CNPJ |
| birth_date | DATE | Data de nascimento |
| gender | ENUM | male, female, other, not_informed |
| email | TEXT | E-mail principal |
| phone | TEXT | Telefone principal |
| whatsapp | TEXT | WhatsApp (pode ser diferente do telefone) |
| status | ENUM | active, inactive, blocked |
| source | ENUM | organic, referral, campaign, whatsapp, instagram, other |
| responsible_user_id | UUID FK → profiles | Responsável (vendedor/atendente) |
| notes | TEXT | Observações gerais |
| avatar_url | TEXT | Foto do cliente |
| last_visit_at | TIMESTAMPTZ | Data da última visita/atendimento |
| total_spent | NUMERIC | Total gasto (desnormalizado, atualizado via trigger) |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `customer_addresses`
Endereços do cliente (pode ter múltiplos).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| customer_id | UUID FK → customers | |
| label | TEXT | Casa, Trabalho, etc. |
| zip_code | TEXT | CEP |
| street | TEXT | Logradouro |
| number | TEXT | Número |
| complement | TEXT | Complemento |
| neighborhood | TEXT | Bairro |
| city | TEXT | Cidade |
| state | TEXT | Estado (UF) |
| country | TEXT | País |
| is_primary | BOOLEAN | Endereço principal |
| created_at | TIMESTAMPTZ | |

#### `customer_tags`
Tags associadas a clientes para segmentação.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| customer_id | UUID FK → customers | |
| tag_id | UUID FK → tags | |
| tenant_id | UUID FK → tenants | |
| created_at | TIMESTAMPTZ | |

#### `customer_notes`
Histórico de notas/observações sobre o cliente.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| customer_id | UUID FK → customers | |
| user_id | UUID FK → profiles | Autor da nota |
| content | TEXT | Conteúdo da nota |
| is_pinned | BOOLEAN | Nota fixada |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `customer_custom_field_values`
Valores de campos customizados por tenant para o perfil do cliente.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| customer_id | UUID FK → customers | |
| custom_field_id | UUID FK → custom_fields | Definição do campo |
| value | TEXT | Valor armazenado como texto |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

---

## Módulo 3 — Agendamento

> Gerencia o núcleo operacional de negócios de serviço: o que se oferece, quem executa e quando.

### Entidades

#### `locations`
Filiais ou unidades físicas de atendimento do tenant.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Nome da unidade |
| address | TEXT | Endereço completo |
| phone | TEXT | Telefone da unidade |
| timezone | TEXT | Fuso horário local |
| is_active | BOOLEAN | Unidade ativa |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `service_categories`
Categorias de serviços oferecidos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Ex: Estética Facial, Consultas, Banho e Tosa |
| color | TEXT | Cor de identificação visual |
| sort_order | INTEGER | Ordem de exibição |
| created_at | TIMESTAMPTZ | |

#### `services`
Serviços oferecidos pelo tenant (procedimentos, consultas, etc.).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| category_id | UUID FK → service_categories | |
| name | TEXT | Nome do serviço |
| description | TEXT | Descrição |
| duration_minutes | INTEGER | Duração padrão em minutos |
| price | NUMERIC | Preço padrão |
| color | TEXT | Cor no calendário |
| max_simultaneous | INTEGER | Atendimentos simultâneos permitidos |
| requires_confirmation | BOOLEAN | Requer confirmação manual |
| is_active | BOOLEAN | Serviço ativo |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `staff_members`
Profissionais que executam serviços (colaboradores do tenant).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| user_id | UUID FK → profiles | Vínculo com conta de usuário (opcional) |
| full_name | TEXT | Nome do profissional |
| email | TEXT | E-mail |
| phone | TEXT | Telefone |
| role | TEXT | Cargo/função (ex: médico, esteticista, atendente) |
| avatar_url | TEXT | Foto |
| calendar_color | TEXT | Cor no calendário |
| is_active | BOOLEAN | Profissional ativo |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `staff_services`
Serviços que cada profissional pode executar.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| staff_member_id | UUID FK → staff_members | |
| service_id | UUID FK → services | |
| tenant_id | UUID FK → tenants | |
| custom_duration_minutes | INTEGER | Duração customizada (override do serviço) |
| custom_price | NUMERIC | Preço customizado (override do serviço) |

#### `staff_locations`
Unidades onde cada profissional atende.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| staff_member_id | UUID FK → staff_members | |
| location_id | UUID FK → locations | |
| tenant_id | UUID FK → tenants | |

#### `staff_schedules`
Grade de horários de trabalho dos profissionais (disponibilidade recorrente).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| staff_member_id | UUID FK → staff_members | |
| location_id | UUID FK → locations | |
| day_of_week | INTEGER | 0=domingo, 6=sábado |
| start_time | TIME | Início do expediente |
| end_time | TIME | Fim do expediente |
| is_working | BOOLEAN | Trabalha neste dia |
| created_at | TIMESTAMPTZ | |

#### `staff_schedule_exceptions`
Exceções à grade padrão (folgas, feriados, horários especiais).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| staff_member_id | UUID FK → staff_members | |
| date | DATE | Data da exceção |
| type | ENUM | day_off, special_hours, vacation |
| start_time | TIME | Início (para special_hours) |
| end_time | TIME | Fim (para special_hours) |
| reason | TEXT | Motivo |
| created_at | TIMESTAMPTZ | |

#### `appointments`
Agendamentos realizados — entidade central do módulo.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| customer_id | UUID FK → customers | |
| staff_member_id | UUID FK → staff_members | |
| location_id | UUID FK → locations | |
| start_at | TIMESTAMPTZ | Data e hora de início |
| end_at | TIMESTAMPTZ | Data e hora de término |
| status | ENUM | scheduled, confirmed, in_progress, completed, cancelled, no_show |
| source | ENUM | manual, online_booking, whatsapp, calendly, google_calendar |
| cancellation_reason | TEXT | Motivo do cancelamento |
| notes | TEXT | Observações do agendamento |
| total_price | NUMERIC | Preço total calculado |
| external_calendar_event_id | TEXT | ID no Google Calendar ou Calendly |
| reminder_sent_at | TIMESTAMPTZ | Data/hora do último lembrete enviado |
| created_by_user_id | UUID FK → profiles | Quem criou o agendamento |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `appointment_services`
Serviços incluídos em um agendamento (um agendamento pode ter múltiplos serviços).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| appointment_id | UUID FK → appointments | |
| service_id | UUID FK → services | |
| price | NUMERIC | Preço cobrado no momento |
| duration_minutes | INTEGER | Duração no momento |
| notes | TEXT | Observação específica do serviço |

#### `appointment_status_history`
Histórico completo de mudanças de status de um agendamento.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| appointment_id | UUID FK → appointments | |
| from_status | ENUM | Status anterior |
| to_status | ENUM | Novo status |
| changed_by_user_id | UUID FK → profiles | |
| reason | TEXT | Motivo da mudança |
| created_at | TIMESTAMPTZ | |

---

## Módulo 4 — CRM

> Gestão de relacionamento, pipeline de vendas/serviços e acompanhamento de oportunidades.

### Entidades

#### `pipelines`
Funis de vendas ou processos do tenant.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Ex: Novos Clientes, Retenção, Vendas |
| description | TEXT | |
| is_default | BOOLEAN | Pipeline padrão |
| is_active | BOOLEAN | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `pipeline_stages`
Etapas dentro de um pipeline.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| pipeline_id | UUID FK → pipelines | |
| name | TEXT | Ex: Lead, Proposta, Negociação, Fechado |
| color | TEXT | Cor da coluna Kanban |
| sort_order | INTEGER | Posição na sequência |
| probability | INTEGER | % de probabilidade de conversão |
| is_won | BOOLEAN | Estágio final de ganho |
| is_lost | BOOLEAN | Estágio final de perda |
| created_at | TIMESTAMPTZ | |

#### `deals`
Negócios/oportunidades em andamento no CRM.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| pipeline_id | UUID FK → pipelines | |
| stage_id | UUID FK → pipeline_stages | |
| customer_id | UUID FK → customers | |
| responsible_user_id | UUID FK → profiles | Responsável pelo deal |
| title | TEXT | Título do negócio |
| value | NUMERIC | Valor estimado |
| expected_close_date | DATE | Data prevista de fechamento |
| status | ENUM | open, won, lost |
| lost_reason | TEXT | Motivo da perda |
| hubspot_deal_id | TEXT | ID de sincronização com HubSpot |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `deal_activities`
Histórico de interações e atividades em um deal.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| deal_id | UUID FK → deals | |
| user_id | UUID FK → profiles | Autor da atividade |
| type | ENUM | note, call, email, whatsapp, meeting, task |
| subject | TEXT | Assunto |
| description | TEXT | Detalhes |
| scheduled_at | TIMESTAMPTZ | Data prevista (para tarefas/reuniões) |
| completed_at | TIMESTAMPTZ | Data de conclusão |
| created_at | TIMESTAMPTZ | |

#### `deal_stage_history`
Histórico de movimentação de deals entre etapas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| deal_id | UUID FK → deals | |
| from_stage_id | UUID FK → pipeline_stages | |
| to_stage_id | UUID FK → pipeline_stages | |
| moved_by_user_id | UUID FK → profiles | |
| created_at | TIMESTAMPTZ | |

---

## Módulo 5 — Marketing

> Criação e execução de campanhas de comunicação com clientes via diferentes canais.

### Entidades

#### `segments`
Segmentos de clientes para targeting de campanhas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Nome do segmento |
| description | TEXT | |
| type | ENUM | static, dynamic |
| customer_count | INTEGER | Contagem de clientes (cache) |
| last_calculated_at | TIMESTAMPTZ | Última vez que o segmento foi calculado |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `segment_rules`
Regras que definem a composição de segmentos dinâmicos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| segment_id | UUID FK → segments | |
| field | TEXT | Campo avaliado (ex: last_visit_at, total_spent) |
| operator | TEXT | eq, gt, lt, contains, between, in |
| value | TEXT | Valor para comparação |
| logic | ENUM | AND, OR |
| sort_order | INTEGER | Ordem de avaliação |

#### `segment_customers`
Membros de segmentos estáticos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| segment_id | UUID FK → segments | |
| customer_id | UUID FK → customers | |
| tenant_id | UUID FK → tenants | |
| added_at | TIMESTAMPTZ | |

#### `message_templates`
Templates reutilizáveis de mensagens para diferentes canais.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Nome interno do template |
| channel | ENUM | whatsapp, email, sms |
| subject | TEXT | Assunto (para email) |
| body | TEXT | Corpo da mensagem com variáveis (ex: {{customer_name}}) |
| variables | JSONB | Lista de variáveis esperadas |
| is_active | BOOLEAN | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `campaigns`
Campanhas de marketing criadas pelo tenant.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Nome da campanha |
| type | ENUM | blast, drip, birthday, reengagement |
| channel | ENUM | whatsapp, email, sms, multi_channel |
| segment_id | UUID FK → segments | Público-alvo |
| template_id | UUID FK → message_templates | Template principal |
| status | ENUM | draft, scheduled, running, paused, completed, cancelled |
| scheduled_at | TIMESTAMPTZ | Data de disparo agendado |
| started_at | TIMESTAMPTZ | Início real do disparo |
| completed_at | TIMESTAMPTZ | Fim do disparo |
| created_by_user_id | UUID FK → profiles | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `campaign_metrics`
Métricas de desempenho por campanha.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| campaign_id | UUID FK → campaigns | |
| total_recipients | INTEGER | Total de destinatários |
| total_sent | INTEGER | Total enviado |
| total_delivered | INTEGER | Total entregue |
| total_opened | INTEGER | Total visualizado/aberto |
| total_clicked | INTEGER | Total de cliques (links) |
| total_replied | INTEGER | Total de respostas |
| total_converted | INTEGER | Total convertido em agendamento/venda |
| total_unsubscribed | INTEGER | Total de descadastros |
| total_failed | INTEGER | Total de falhas no envio |
| updated_at | TIMESTAMPTZ | |

#### `campaign_message_logs`
Log de envio por mensagem individual (rastreabilidade).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| campaign_id | UUID FK → campaigns | |
| customer_id | UUID FK → customers | |
| channel | ENUM | whatsapp, email, sms |
| status | ENUM | queued, sent, delivered, opened, failed, unsubscribed |
| sent_at | TIMESTAMPTZ | |
| delivered_at | TIMESTAMPTZ | |
| opened_at | TIMESTAMPTZ | |
| error_message | TEXT | Mensagem de erro se falhou |
| external_message_id | TEXT | ID no provedor (ManyChat, etc.) |
| created_at | TIMESTAMPTZ | |

---

## Módulo 6 — Automações

> Motor de automação de fluxos de trabalho baseado em gatilhos, condições e ações.

### Entidades

#### `automations`
Definição de um workflow de automação.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Nome da automação |
| description | TEXT | |
| status | ENUM | active, inactive, draft |
| trigger_type | ENUM | appointment_created, appointment_cancelled, customer_created, deal_stage_changed, birthday, date_based, manual, webhook |
| trigger_config | JSONB | Configuração específica do gatilho |
| created_by_user_id | UUID FK → profiles | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `automation_steps`
Passos sequenciais de uma automação (ações e condições encadeadas).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| automation_id | UUID FK → automations | |
| parent_step_id | UUID FK → automation_steps | Passo anterior (para ramificações) |
| type | ENUM | action, condition, delay, branch |
| action_type | ENUM | send_whatsapp, send_email, create_deal, update_customer, add_tag, notify_user, call_webhook |
| condition_config | JSONB | Configuração da condição (campo, operador, valor) |
| action_config | JSONB | Configuração da ação |
| delay_config | JSONB | Configuração do atraso (ex: aguardar 1 dia) |
| sort_order | INTEGER | Posição no fluxo |
| created_at | TIMESTAMPTZ | |

#### `automation_runs`
Instâncias de execução de uma automação (por cliente/trigger).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| automation_id | UUID FK → automations | |
| trigger_entity_type | TEXT | customers, appointments, deals |
| trigger_entity_id | UUID | ID da entidade que disparou |
| status | ENUM | running, completed, failed, cancelled |
| started_at | TIMESTAMPTZ | |
| completed_at | TIMESTAMPTZ | |
| error_message | TEXT | |
| created_at | TIMESTAMPTZ | |

#### `automation_run_logs`
Log detalhado de cada passo executado em uma run.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| automation_run_id | UUID FK → automation_runs | |
| automation_step_id | UUID FK → automation_steps | |
| status | ENUM | success, skipped, failed |
| output | JSONB | Resultado da execução |
| error_message | TEXT | |
| executed_at | TIMESTAMPTZ | |

---

## Módulo 7 — Integrações

> Configurações e dados sincronizados das integrações com ferramentas externas.

### Entidades

#### `integrations`
Integrações habilitadas por tenant.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| provider | ENUM | hubspot, manychat, whatsapp, google_calendar, calendly, meta_ads |
| status | ENUM | connected, disconnected, error |
| connected_at | TIMESTAMPTZ | |
| last_sync_at | TIMESTAMPTZ | |
| config | JSONB | Configurações específicas da integração (sem secrets) |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `integration_credentials`
Tokens e credenciais de acesso às integrações (armazenados com criptografia em nível de aplicação).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| integration_id | UUID FK → integrations | |
| key_name | TEXT | Nome da credencial (access_token, api_key, etc.) |
| encrypted_value | TEXT | Valor criptografado |
| expires_at | TIMESTAMPTZ | Expiração do token (para OAuth) |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `integration_sync_logs`
Histórico de sincronizações realizadas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| integration_id | UUID FK → integrations | |
| direction | ENUM | inbound, outbound |
| entity_type | TEXT | customers, deals, appointments, etc. |
| external_id | TEXT | ID no sistema externo |
| internal_id | UUID | ID interno correspondente |
| status | ENUM | success, failed, skipped |
| error_message | TEXT | |
| synced_at | TIMESTAMPTZ | |

#### `whatsapp_conversations`
Conversas de WhatsApp vinculadas a clientes.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| customer_id | UUID FK → customers | |
| phone_number | TEXT | Número do cliente no WhatsApp |
| external_conversation_id | TEXT | ID no ManyChat/WhatsApp |
| status | ENUM | open, closed, waiting |
| last_message_at | TIMESTAMPTZ | |
| assigned_user_id | UUID FK → profiles | Atendente responsável |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `whatsapp_messages`
Mensagens individuais de conversas de WhatsApp.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| conversation_id | UUID FK → whatsapp_conversations | |
| direction | ENUM | inbound, outbound |
| content | TEXT | Conteúdo da mensagem |
| type | ENUM | text, image, audio, document, template |
| media_url | TEXT | URL de mídia (para não-texto) |
| status | ENUM | sent, delivered, read, failed |
| external_message_id | TEXT | ID na API do WhatsApp |
| sent_at | TIMESTAMPTZ | |
| delivered_at | TIMESTAMPTZ | |
| read_at | TIMESTAMPTZ | |
| created_at | TIMESTAMPTZ | |

#### `webhooks`
Webhooks configurados pelo tenant para receber eventos externos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Nome descritivo |
| url | TEXT | URL de destino (para outbound) |
| event_types | JSONB | Lista de eventos subscritos |
| secret_hash | TEXT | Hash de validação da assinatura |
| is_active | BOOLEAN | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

---

## Módulo 8 — Relatórios & Analytics

> Dados de performance e comportamento para tomada de decisão.

### Entidades

#### `analytics_events`
Registro de eventos de comportamento para análise (event sourcing leve).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| event_type | TEXT | appointment.completed, customer.created, deal.won, etc. |
| entity_type | TEXT | Tipo da entidade relacionada |
| entity_id | UUID | ID da entidade relacionada |
| user_id | UUID FK → profiles | Usuário que gerou o evento (se aplicável) |
| metadata | JSONB | Dados adicionais do evento |
| occurred_at | TIMESTAMPTZ | Momento do evento |

#### `dashboards`
Dashboards configurados por tenant.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Nome do dashboard |
| is_default | BOOLEAN | Dashboard inicial do módulo |
| created_by_user_id | UUID FK → profiles | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `dashboard_widgets`
Widgets configurados dentro de um dashboard.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| dashboard_id | UUID FK → dashboards | |
| widget_type | ENUM | metric_card, bar_chart, line_chart, pie_chart, table, funnel |
| title | TEXT | Título do widget |
| config | JSONB | Configuração (métricas, filtros, período) |
| position | JSONB | Posição e tamanho no grid (x, y, w, h) |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

#### `saved_reports`
Relatórios salvos com configurações de filtro e visualização.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Nome do relatório |
| module | TEXT | scheduling, crm, marketing, customers |
| config | JSONB | Colunas, filtros, ordenação, agrupamentos |
| schedule | JSONB | Configuração de envio automático (cron) |
| created_by_user_id | UUID FK → profiles | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

---

## Módulo 9 — Configurações

> Configurações globais e personalizações de comportamento do sistema por tenant.

### Entidades

#### `tenant_settings`
Configurações gerais do tenant (1:1 com tenant).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| tenant_id | UUID PK FK → tenants | |
| booking_lead_time_hours | INTEGER | Antecedência mínima para agendamento online |
| booking_max_future_days | INTEGER | Máximo de dias à frente para agendamento |
| cancellation_policy_hours | INTEGER | Horas de antecedência para cancelamento |
| reminder_hours_before | INTEGER | Horas antes para envio de lembrete |
| reminder_channel | ENUM | whatsapp, email, both |
| auto_confirm_appointments | BOOLEAN | Confirmar agendamentos automaticamente |
| online_booking_enabled | BOOLEAN | Link de agendamento público ativo |
| business_hours | JSONB | Horário de funcionamento por dia da semana |
| updated_at | TIMESTAMPTZ | |

#### `notification_settings`
Preferências de notificações por usuário dentro de um tenant.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| user_id | UUID FK → profiles | |
| new_appointment | BOOLEAN | Notificar novo agendamento |
| appointment_cancelled | BOOLEAN | Notificar cancelamento |
| new_message_whatsapp | BOOLEAN | Notificar nova mensagem |
| new_deal | BOOLEAN | Notificar novo deal |
| daily_summary | BOOLEAN | Resumo diário |
| channel | ENUM | in_app, email, whatsapp |
| updated_at | TIMESTAMPTZ | |

#### `custom_fields`
Definição de campos customizados criados pelo tenant para estender entidades padrão.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| entity_type | ENUM | customer, appointment, deal | Entidade que recebe o campo |
| label | TEXT | Label exibido na interface |
| field_key | TEXT | Chave técnica (ex: tipo_de_pele) |
| field_type | ENUM | text, number, date, select, multi_select, boolean |
| options | JSONB | Opções para select/multi_select |
| is_required | BOOLEAN | Campo obrigatório |
| sort_order | INTEGER | Ordem de exibição |
| is_active | BOOLEAN | |
| created_at | TIMESTAMPTZ | |

#### `tags`
Tags disponíveis no tenant para categorizar clientes, deals e outras entidades.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | Nome da tag |
| color | TEXT | Cor de exibição |
| entity_type | ENUM | customer, deal, appointment | Entidade que pode receber a tag |
| created_at | TIMESTAMPTZ | |

---

## Mapa de Relacionamentos

```
tenants
  ├── subscriptions → plans
  ├── invoices
  ├── tenant_users → profiles (auth.users)
  │     └── roles → role_permissions → permissions
  ├── customers
  │     ├── customer_addresses
  │     ├── customer_tags → tags
  │     ├── customer_notes
  │     └── customer_custom_field_values → custom_fields
  ├── locations
  ├── service_categories
  ├── services → service_categories
  ├── staff_members
  │     ├── staff_services → services
  │     ├── staff_locations → locations
  │     ├── staff_schedules
  │     └── staff_schedule_exceptions
  ├── appointments → customers, staff_members, locations
  │     ├── appointment_services → services
  │     └── appointment_status_history
  ├── pipelines
  │     └── pipeline_stages
  ├── deals → customers, pipelines, pipeline_stages
  │     ├── deal_activities
  │     └── deal_stage_history
  ├── segments
  │     ├── segment_rules
  │     └── segment_customers → customers
  ├── message_templates
  ├── campaigns → segments, message_templates
  │     ├── campaign_metrics
  │     └── campaign_message_logs → customers
  ├── automations
  │     ├── automation_steps
  │     ├── automation_runs
  │     └── automation_run_logs
  ├── integrations
  │     ├── integration_credentials
  │     └── integration_sync_logs
  ├── whatsapp_conversations → customers
  │     └── whatsapp_messages
  ├── webhooks
  ├── analytics_events
  ├── dashboards → dashboard_widgets
  ├── saved_reports
  ├── tenant_settings
  ├── notification_settings → profiles
  ├── custom_fields
  └── tags
```

---

## Princípios de Design Aplicados

### 1. Multi-Tenant First
Toda tabela possui `tenant_id`. RLS do PostgreSQL garante que nenhuma query de aplicação vaze dados entre tenants.

### 2. Soft Relations com Integrações Externas
Campos como `hubspot_deal_id`, `external_calendar_event_id`, `external_message_id` permitem rastrear entidades externas sem depender de joins — mantendo a integridade mesmo quando a integração está desconectada.

### 3. Histórico e Auditoria
Entidades críticas possuem tabelas de histórico de status (`appointment_status_history`, `deal_stage_history`) para auditabilidade completa sem depender de CDC (Change Data Capture).

### 4. JSONB para Flexibilidade
Campos como `config`, `trigger_config`, `action_config`, `metadata` usam JSONB para acomodar variações por tipo de integração/automação sem exigir dezenas de colunas esparsas ou múltiplas tabelas polimórficas.

### 5. Custom Fields sem EAV complexo
Campos customizados seguem o padrão EAV (Entity-Attribute-Value) simplificado: `custom_fields` define o schema, `customer_custom_field_values` armazena os valores. Escalável sem alterar o schema do banco a cada novo campo do cliente.

### 6. Credentials Separadas
`integration_credentials` é separada de `integrations` para que os dados de configuração (não-sensíveis) possam ser lidos por componentes da aplicação sem expor tokens e API keys.

### 7. Event Sourcing Leve
`analytics_events` captura eventos de negócio em append-only para análises históricas sem impactar a performance das tabelas transacionais.

---

## Contagem de Entidades por Módulo

| Módulo | Entidades |
|--------|-----------|
| Core / Foundation | 4 |
| Auth & Usuários | 5 |
| Clientes | 5 |
| Agendamento | 10 |
| CRM | 5 |
| Marketing | 6 |
| Automações | 4 |
| Integrações | 6 |
| Relatórios & Analytics | 4 |
| Configurações | 5 |
| **Total** | **54** |

---

*Documento gerado na fase de Planejamento & Arquitetura. Nenhuma implementação SQL deve ser iniciada sem aprovação desta arquitetura.*
