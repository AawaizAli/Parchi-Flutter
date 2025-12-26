generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  schemas  = ["auth", "public"]
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model audit_log_entries {
  instance_id String?   @db.Uuid
  id          String    @id @db.Uuid
  payload     Json?     @db.Json
  created_at  DateTime? @db.Timestamptz(6)
  ip_address  String    @default("") @db.VarChar(64)

  @@index([instance_id], map: "audit_logs_instance_id_idx")
  @@schema("auth")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model flow_state {
  id                     String                @id @db.Uuid
  user_id                String?               @db.Uuid
  auth_code              String
  code_challenge_method  code_challenge_method
  code_challenge         String
  provider_type          String
  provider_access_token  String?
  provider_refresh_token String?
  created_at             DateTime?             @db.Timestamptz(6)
  updated_at             DateTime?             @db.Timestamptz(6)
  authentication_method  String
  auth_code_issued_at    DateTime?             @db.Timestamptz(6)
  saml_relay_states      saml_relay_states[]

  @@index([created_at(sort: Desc)])
  @@index([auth_code], map: "idx_auth_code")
  @@index([user_id, authentication_method], map: "idx_user_id_auth_method")
  @@schema("auth")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model identities {
  provider_id     String
  user_id         String     @db.Uuid
  identity_data   Json
  provider        String
  last_sign_in_at DateTime?  @db.Timestamptz(6)
  created_at      DateTime?  @db.Timestamptz(6)
  updated_at      DateTime?  @db.Timestamptz(6)
  email           String?    @default(dbgenerated("lower((identity_data ->> 'email'::text))"))
  id              String     @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  users           auth_users @relation(fields: [user_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([provider_id, provider], map: "identities_provider_id_provider_unique")
  @@index([email])
  @@index([user_id])
  @@schema("auth")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model instances {
  id              String    @id @db.Uuid
  uuid            String?   @db.Uuid
  raw_base_config String?
  created_at      DateTime? @db.Timestamptz(6)
  updated_at      DateTime? @db.Timestamptz(6)

  @@schema("auth")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model mfa_amr_claims {
  session_id            String   @db.Uuid
  created_at            DateTime @db.Timestamptz(6)
  updated_at            DateTime @db.Timestamptz(6)
  authentication_method String
  id                    String   @id(map: "amr_id_pk") @db.Uuid
  sessions              sessions @relation(fields: [session_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([session_id, authentication_method], map: "mfa_amr_claims_session_id_authentication_method_pkey")
  @@schema("auth")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model mfa_challenges {
  id                     String      @id @db.Uuid
  factor_id              String      @db.Uuid
  created_at             DateTime    @db.Timestamptz(6)
  verified_at            DateTime?   @db.Timestamptz(6)
  ip_address             String      @db.Inet
  otp_code               String?
  web_authn_session_data Json?
  mfa_factors            mfa_factors @relation(fields: [factor_id], references: [id], onDelete: Cascade, onUpdate: NoAction, map: "mfa_challenges_auth_factor_id_fkey")

  @@index([created_at(sort: Desc)], map: "mfa_challenge_created_at_idx")
  @@schema("auth")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model mfa_factors {
  id                           String           @id @db.Uuid
  user_id                      String           @db.Uuid
  friendly_name                String?
  factor_type                  factor_type
  status                       factor_status
  created_at                   DateTime         @db.Timestamptz(6)
  updated_at                   DateTime         @db.Timestamptz(6)
  secret                       String?
  phone                        String?
  last_challenged_at           DateTime?        @unique @db.Timestamptz(6)
  web_authn_credential         Json?
  web_authn_aaguid             String?          @db.Uuid
  last_webauthn_challenge_data Json?
  mfa_challenges               mfa_challenges[]
  users                        auth_users       @relation(fields: [user_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([user_id, phone], map: "unique_phone_factor_per_user")
  @@index([user_id, created_at], map: "factor_id_created_at_idx")
  @@index([user_id])
  @@schema("auth")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model oauth_authorizations {
  id                    String                     @id @db.Uuid
  authorization_id      String                     @unique
  client_id             String                     @db.Uuid
  user_id               String?                    @db.Uuid
  redirect_uri          String
  scope                 String
  state                 String?
  resource              String?
  code_challenge        String?
  code_challenge_method code_challenge_method?
  response_type         oauth_response_type        @default(code)
  status                oauth_authorization_status @default(pending)
  authorization_code    String?                    @unique
  created_at            DateTime                   @default(now()) @db.Timestamptz(6)
  expires_at            DateTime                   @default(dbgenerated("(now() + '00:03:00'::interval)")) @db.Timestamptz(6)
  approved_at           DateTime?                  @db.Timestamptz(6)
  nonce                 String?
  oauth_clients         oauth_clients              @relation(fields: [client_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  users                 auth_users?                @relation(fields: [user_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@schema("auth")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model oauth_clients {
  id                   String                  @id @db.Uuid
  client_secret_hash   String?
  registration_type    oauth_registration_type
  redirect_uris        String
  grant_types          String
  client_name          String?
  client_uri           String?
  logo_uri             String?
  created_at           DateTime                @default(now()) @db.Timestamptz(6)
  updated_at           DateTime                @default(now()) @db.Timestamptz(6)
  deleted_at           DateTime?               @db.Timestamptz(6)
  client_type          oauth_client_type       @default(confidential)
  oauth_authorizations oauth_authorizations[]
  oauth_consents       oauth_consents[]
  sessions             sessions[]

  @@index([deleted_at])
  @@schema("auth")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model oauth_consents {
  id            String        @id @db.Uuid
  user_id       String        @db.Uuid
  client_id     String        @db.Uuid
  scopes        String
  granted_at    DateTime      @default(now()) @db.Timestamptz(6)
  revoked_at    DateTime?     @db.Timestamptz(6)
  oauth_clients oauth_clients @relation(fields: [client_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  users         auth_users    @relation(fields: [user_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([user_id, client_id], map: "oauth_consents_user_client_unique")
  @@index([user_id, granted_at(sort: Desc)], map: "oauth_consents_user_order_idx")
  @@schema("auth")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model one_time_tokens {
  id         String              @id @db.Uuid
  user_id    String              @db.Uuid
  token_type one_time_token_type
  token_hash String
  relates_to String
  created_at DateTime            @default(now()) @db.Timestamp(6)
  updated_at DateTime            @default(now()) @db.Timestamp(6)
  users      auth_users          @relation(fields: [user_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([user_id, token_type])
  @@index([relates_to], map: "one_time_tokens_relates_to_hash_idx", type: Hash)
  @@index([token_hash], map: "one_time_tokens_token_hash_hash_idx", type: Hash)
  @@schema("auth")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model refresh_tokens {
  instance_id String?   @db.Uuid
  id          BigInt    @id @default(autoincrement())
  token       String?   @unique(map: "refresh_tokens_token_unique") @db.VarChar(255)
  user_id     String?   @db.VarChar(255)
  revoked     Boolean?
  created_at  DateTime? @db.Timestamptz(6)
  updated_at  DateTime? @db.Timestamptz(6)
  parent      String?   @db.VarChar(255)
  session_id  String?   @db.Uuid
  sessions    sessions? @relation(fields: [session_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@index([instance_id])
  @@index([instance_id, user_id])
  @@index([parent])
  @@index([session_id, revoked])
  @@index([updated_at(sort: Desc)])
  @@schema("auth")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model saml_providers {
  id                String        @id @db.Uuid
  sso_provider_id   String        @db.Uuid
  entity_id         String        @unique
  metadata_xml      String
  metadata_url      String?
  attribute_mapping Json?
  created_at        DateTime?     @db.Timestamptz(6)
  updated_at        DateTime?     @db.Timestamptz(6)
  name_id_format    String?
  sso_providers     sso_providers @relation(fields: [sso_provider_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@index([sso_provider_id])
  @@schema("auth")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model saml_relay_states {
  id              String        @id @db.Uuid
  sso_provider_id String        @db.Uuid
  request_id      String
  for_email       String?
  redirect_to     String?
  created_at      DateTime?     @db.Timestamptz(6)
  updated_at      DateTime?     @db.Timestamptz(6)
  flow_state_id   String?       @db.Uuid
  flow_state      flow_state?   @relation(fields: [flow_state_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  sso_providers   sso_providers @relation(fields: [sso_provider_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@index([created_at(sort: Desc)])
  @@index([for_email])
  @@index([sso_provider_id])
  @@schema("auth")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model schema_migrations {
  version String @id @db.VarChar(255)

  @@schema("auth")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
model sessions {
  id                     String           @id @db.Uuid
  user_id                String           @db.Uuid
  created_at             DateTime?        @db.Timestamptz(6)
  updated_at             DateTime?        @db.Timestamptz(6)
  factor_id              String?          @db.Uuid
  aal                    aal_level?
  not_after              DateTime?        @db.Timestamptz(6)
  refreshed_at           DateTime?        @db.Timestamp(6)
  user_agent             String?
  ip                     String?          @db.Inet
  tag                    String?
  oauth_client_id        String?          @db.Uuid
  refresh_token_hmac_key String?
  refresh_token_counter  BigInt?
  scopes                 String?
  mfa_amr_claims         mfa_amr_claims[]
  refresh_tokens         refresh_tokens[]
  oauth_clients          oauth_clients?   @relation(fields: [oauth_client_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  users                  auth_users       @relation(fields: [user_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@index([not_after(sort: Desc)])
  @@index([oauth_client_id])
  @@index([user_id])
  @@index([user_id, created_at], map: "user_id_created_at_idx")
  @@schema("auth")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
/// This model contains an expression index which requires additional setup for migrations. Visit https://pris.ly/d/expression-indexes for more info.
model sso_domains {
  id              String        @id @db.Uuid
  sso_provider_id String        @db.Uuid
  domain          String
  created_at      DateTime?     @db.Timestamptz(6)
  updated_at      DateTime?     @db.Timestamptz(6)
  sso_providers   sso_providers @relation(fields: [sso_provider_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@index([sso_provider_id])
  @@schema("auth")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
/// This model contains an expression index which requires additional setup for migrations. Visit https://pris.ly/d/expression-indexes for more info.
model sso_providers {
  id                String              @id @db.Uuid
  resource_id       String?
  created_at        DateTime?           @db.Timestamptz(6)
  updated_at        DateTime?           @db.Timestamptz(6)
  disabled          Boolean?
  saml_providers    saml_providers[]
  saml_relay_states saml_relay_states[]
  sso_domains       sso_domains[]

  @@index([resource_id], map: "sso_providers_resource_id_pattern_idx")
  @@schema("auth")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
/// This model contains row level security and requires additional setup for migrations. Visit https://pris.ly/d/row-level-security for more info.
/// This model contains an expression index which requires additional setup for migrations. Visit https://pris.ly/d/expression-indexes for more info.
model auth_users {
  instance_id                 String?                @db.Uuid
  id                          String                 @id @db.Uuid
  aud                         String?                @db.VarChar(255)
  role                        String?                @db.VarChar(255)
  email                       String?                @db.VarChar(255)
  encrypted_password          String?                @db.VarChar(255)
  email_confirmed_at          DateTime?              @db.Timestamptz(6)
  invited_at                  DateTime?              @db.Timestamptz(6)
  confirmation_token          String?                @db.VarChar(255)
  confirmation_sent_at        DateTime?              @db.Timestamptz(6)
  recovery_token              String?                @db.VarChar(255)
  recovery_sent_at            DateTime?              @db.Timestamptz(6)
  email_change_token_new      String?                @db.VarChar(255)
  email_change                String?                @db.VarChar(255)
  email_change_sent_at        DateTime?              @db.Timestamptz(6)
  last_sign_in_at             DateTime?              @db.Timestamptz(6)
  raw_app_meta_data           Json?
  raw_user_meta_data          Json?
  is_super_admin              Boolean?
  created_at                  DateTime?              @db.Timestamptz(6)
  updated_at                  DateTime?              @db.Timestamptz(6)
  phone                       String?                @unique
  phone_confirmed_at          DateTime?              @db.Timestamptz(6)
  phone_change                String?                @default("")
  phone_change_token          String?                @default("") @db.VarChar(255)
  phone_change_sent_at        DateTime?              @db.Timestamptz(6)
  confirmed_at                DateTime?              @default(dbgenerated("LEAST(email_confirmed_at, phone_confirmed_at)")) @db.Timestamptz(6)
  email_change_token_current  String?                @default("") @db.VarChar(255)
  email_change_confirm_status Int?                   @default(0) @db.SmallInt
  banned_until                DateTime?              @db.Timestamptz(6)
  reauthentication_token      String?                @default("") @db.VarChar(255)
  reauthentication_sent_at    DateTime?              @db.Timestamptz(6)
  is_sso_user                 Boolean                @default(false)
  deleted_at                  DateTime?              @db.Timestamptz(6)
  is_anonymous                Boolean                @default(false)
  identities                  identities[]
  mfa_factors                 mfa_factors[]
  oauth_authorizations        oauth_authorizations[]
  oauth_consents              oauth_consents[]
  one_time_tokens             one_time_tokens[]
  sessions                    sessions[]
  users                       public_users?

  @@index([instance_id])
  @@index([is_anonymous])
  @@map("users")
  @@schema("auth")
}

model audit_logs {
  id         String        @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  user_id    String?       @db.Uuid
  action     String        @db.VarChar(100)
  table_name String?       @db.VarChar(100)
  record_id  String?       @db.Uuid
  old_values Json?
  new_values Json?
  ip_address String?       @db.Inet
  user_agent String?
  created_at DateTime?     @default(now()) @db.Timestamptz(6)
  users      public_users? @relation(fields: [user_id], references: [id], onDelete: NoAction, onUpdate: NoAction)

  @@index([action], map: "idx_audit_action")
  @@index([created_at], map: "idx_audit_created")
  @@index([user_id], map: "idx_audit_user")
  @@schema("public")
}

model branch_bonus_settings {
  id                   String            @id(map: "merchant_bonus_settings_pkey") @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  branch_id            String            @unique @db.Uuid
  image_url            String?
  redemptions_required Int               @default(5)
  discount_type        String            @default("percentage") @db.VarChar(20)
  discount_value       Decimal           @db.Decimal(10, 2)
  max_discount_amount  Decimal?          @db.Decimal(10, 2)
  validity_days        Int?              @default(30)
  is_active            Boolean?          @default(true)
  created_at           DateTime?         @default(now()) @db.Timestamptz(6)
  updated_at           DateTime?         @default(now()) @db.Timestamptz(6)
  merchant_branches    merchant_branches @relation(fields: [branch_id], references: [id], onDelete: Cascade)

  @@schema("public")
}

model merchant_branches {
  id                    String                 @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  merchant_id           String                 @db.Uuid
  user_id               String?                @unique @db.Uuid
  branch_name           String                 @db.VarChar(255)
  address               String
  city                  String                 @db.VarChar(100)
  latitude              Decimal?               @db.Decimal(10, 8)
  longitude             Decimal?               @db.Decimal(11, 8)
  contact_phone         String?                @db.VarChar(20)
  is_active             Boolean?               @default(true)
  created_at            DateTime?              @default(now()) @db.Timestamptz(6)
  updated_at            DateTime?              @default(now()) @db.Timestamptz(6)
  branch_bonus_settings branch_bonus_settings?
  merchants             merchants              @relation(fields: [merchant_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  users                 public_users?          @relation(fields: [user_id], references: [id], onUpdate: NoAction)
  offer_branches        offer_branches[]
  redemptions           redemptions[]
  student_branch_stats  student_branch_stats[]

  @@index([city], map: "idx_branches_location")
  @@index([merchant_id], map: "idx_branches_merchant")
  @@schema("public")
}

model merchants {
  id                           String                   @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  user_id                      String                   @unique @db.Uuid
  business_name                String                   @db.VarChar(255)
  business_registration_number String?                  @db.VarChar(100)
  contact_email                String                   @db.VarChar(255)
  contact_phone                String                   @db.VarChar(20)
  logo_path                    String?
  category                     String?                  @db.VarChar(100)
  verification_status          verification_status?     @default(pending)
  verified_at                  DateTime?                @db.Timestamptz(6)
  is_active                    Boolean?                 @default(true)
  created_at                   DateTime?                @default(now()) @db.Timestamptz(6)
  updated_at                   DateTime?                @default(now()) @db.Timestamptz(6)
  email_prefix                 String?                  @db.VarChar(100)
  merchant_branches            merchant_branches[]
  users                        public_users             @relation(fields: [user_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  offers                       offers[]
  student_merchant_stats       student_merchant_stats[]

  @@index([verification_status], map: "idx_merchants_status")
  @@schema("public")
}

model offer_branches {
  id                String            @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  offer_id          String            @db.Uuid
  branch_id         String            @db.Uuid
  is_active         Boolean?          @default(true)
  merchant_branches merchant_branches @relation(fields: [branch_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  offers            offers            @relation(fields: [offer_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([offer_id, branch_id])
  @@schema("public")
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model offers {
  id                  String           @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  merchant_id         String           @db.Uuid
  title               String           @db.VarChar(255)
  description         String?
  image_url           String?
  discount_type       String           @db.VarChar(20)
  discount_value      Decimal          @db.Decimal(10, 2)
  min_order_value     Decimal?         @default(0) @db.Decimal(10, 2)
  max_discount_amount Decimal?         @db.Decimal(10, 2)
  terms_conditions    String?
  valid_from          DateTime         @db.Timestamptz(6)
  valid_until         DateTime         @db.Timestamptz(6)
  daily_limit         Int?
  total_limit         Int?
  current_redemptions Int?             @default(0)
  status              offer_status?    @default(active)
  created_by          String?          @db.Uuid
  created_at          DateTime?        @default(now()) @db.Timestamptz(6)
  updated_at          DateTime?        @default(now()) @db.Timestamptz(6)
  schedule_type       String?          @default("always") @db.VarChar(20)
  allowed_days        Int[]
  start_time          DateTime?        @db.Time(0)
  end_time            DateTime?        @db.Time(0)
  offer_branches      offer_branches[]
  users               public_users?    @relation(fields: [created_by], references: [id], onDelete: NoAction, onUpdate: NoAction)
  merchants           merchants        @relation(fields: [merchant_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  redemptions         redemptions[]

  @@index([merchant_id], map: "idx_offers_merchant")
  @@index([status], map: "idx_offers_status")
  @@index([valid_from, valid_until], map: "idx_offers_validity")
  @@index([status, valid_from, valid_until, created_at(sort: Desc)], map: "idx_offers_active_valid_created")
  @@index([merchant_id, status, created_at(sort: Desc)], map: "idx_offers_merchant_status_created")
  @@index([merchant_id, status, valid_from, valid_until, created_at(sort: Desc)], map: "idx_offers_merchant_active_valid_created")
  @@index([created_at(sort: Desc)], map: "idx_offers_created")
  @@schema("public")
}

model rate_limits {
  id           String    @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  identifier   String    @db.VarChar(255)
  action       String    @db.VarChar(100)
  attempts     Int?      @default(1)
  window_start DateTime? @default(now()) @db.Timestamptz(6)

  @@unique([identifier, action])
  @@schema("public")
}

model redemptions {
  id                     String            @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  student_id             String            @db.Uuid
  offer_id               String            @db.Uuid
  branch_id              String            @db.Uuid
  is_bonus_applied       Boolean?          @default(false)
  bonus_discount_applied Decimal?          @db.Decimal(12, 2)
  verified_by            String?           @db.Uuid
  notes                  String?
  created_at             DateTime?         @default(now()) @db.Timestamptz(6)
  merchant_branches      merchant_branches @relation(fields: [branch_id], references: [id], onDelete: NoAction, onUpdate: NoAction)
  offers                 offers            @relation(fields: [offer_id], references: [id], onDelete: NoAction, onUpdate: NoAction)
  students               students          @relation(fields: [student_id], references: [id], onDelete: NoAction, onUpdate: NoAction)
  users                  public_users?     @relation(fields: [verified_by], references: [id], onDelete: NoAction, onUpdate: NoAction)

  @@index([branch_id], map: "idx_redemptions_branch")
  @@index([created_at], map: "idx_redemptions_created")
  @@index([offer_id], map: "idx_redemptions_offer")
  @@index([student_id], map: "idx_redemptions_student")
  @@schema("public")
}

model student_branch_stats {
  id                 String            @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  student_id         String            @db.Uuid
  branch_id          String            @db.Uuid
  redemption_count   Int?              @default(0)
  total_savings      Decimal?          @default(0.00) @db.Decimal(12, 2)
  last_redemption_at DateTime?         @db.Timestamptz(6)
  merchant_branches  merchant_branches @relation(fields: [branch_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  students           students          @relation(fields: [student_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([student_id, branch_id])
  @@schema("public")
}

model student_kyc {
  id                         String        @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  student_id                 String        @db.Uuid
  selfie_image_path          String
  submitted_at               DateTime?     @default(now()) @db.Timestamptz(6)
  reviewed_by                String?       @db.Uuid
  reviewed_at                DateTime?     @db.Timestamptz(6)
  review_notes               String?
  is_annual_renewal          Boolean?      @default(false)
  created_at                 DateTime?     @default(now()) @db.Timestamptz(6)
  student_id_card_front_path String?
  student_id_card_back_path  String?
  users                      public_users? @relation(fields: [reviewed_by], references: [id], onDelete: NoAction, onUpdate: NoAction)
  students                   students      @relation(fields: [student_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@schema("public")
}

model student_merchant_stats {
  id                 String    @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  student_id         String    @db.Uuid
  merchant_id        String    @db.Uuid
  redemption_count   Int?      @default(0)
  total_savings      Decimal?  @default(0.00) @db.Decimal(12, 2)
  last_redemption_at DateTime? @db.Timestamptz(6)
  merchants          merchants @relation(fields: [merchant_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  students           students  @relation(fields: [student_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([student_id, merchant_id])
  @@index([student_id, merchant_id], map: "idx_student_merchant_stats")
  @@schema("public")
}

model students {
  id                       String                   @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  user_id                  String                   @unique @db.Uuid
  parchi_id                String                   @unique @db.VarChar(10)
  first_name               String                   @db.VarChar(100)
  last_name                String                   @db.VarChar(100)
  university               String                   @db.VarChar(255)
  graduation_year          Int?
  is_founders_club         Boolean?                 @default(false)
  total_savings            Decimal?                 @default(0.00) @db.Decimal(12, 2)
  total_redemptions        Int?                     @default(0)
  verification_status      verification_status?     @default(pending)
  verified_at              DateTime?                @db.Timestamptz(6)
  verification_expires_at  DateTime?                @db.Timestamptz(6)
  created_at               DateTime?                @default(now()) @db.Timestamptz(6)
  updated_at               DateTime?                @default(now()) @db.Timestamptz(6)
  profile_picture          String?
  verification_selfie_path String?
  redemptions              redemptions[]
  student_branch_stats     student_branch_stats[]
  student_kyc              student_kyc[]
  student_merchant_stats   student_merchant_stats[]
  users                    public_users             @relation(fields: [user_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@index([parchi_id], map: "idx_students_parchi_id")
  @@index([user_id], map: "idx_students_user")
  @@index([verification_status], map: "idx_students_verification")
  @@schema("public")
}

model system_logs {
  id         String    @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  level      String    @db.VarChar(20)
  message    String
  metadata   Json?
  created_at DateTime? @default(now()) @db.Timestamptz(6)

  @@schema("public")
}

model public_users {
  id                String             @id @db.Uuid
  email             String             @unique @db.VarChar(255)
  phone             String?            @db.VarChar(20)
  role              user_role
  is_active         Boolean?           @default(true)
  created_at        DateTime?          @default(now()) @db.Timestamptz(6)
  updated_at        DateTime?          @default(now()) @db.Timestamptz(6)
  audit_logs        audit_logs[]
  merchant_branches merchant_branches?
  merchants         merchants?
  offers            offers[]
  redemptions       redemptions[]
  student_kyc       student_kyc[]
  students          students?
  users             auth_users         @relation(fields: [id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@map("users")
  @@schema("public")
}

/// This model or at least one of its fields has comments in the database, and requires an additional setup for migrations: Read more: https://pris.ly/d/database-comments
model oauth_client_states {
  id            String   @id @db.Uuid
  provider_type String
  code_verifier String?
  created_at    DateTime @db.Timestamptz(6)

  @@index([created_at], map: "idx_oauth_client_states_created_at")
  @@schema("auth")
}

enum aal_level {
  aal1
  aal2
  aal3

  @@schema("auth")
}

enum code_challenge_method {
  s256
  plain

  @@schema("auth")
}

enum factor_status {
  unverified
  verified

  @@schema("auth")
}

enum factor_type {
  totp
  webauthn
  phone

  @@schema("auth")
}

enum oauth_authorization_status {
  pending
  approved
  denied
  expired

  @@schema("auth")
}

enum oauth_client_type {
  public
  confidential

  @@schema("auth")
}

enum oauth_registration_type {
  dynamic
  manual

  @@schema("auth")
}

enum oauth_response_type {
  code

  @@schema("auth")
}

enum one_time_token_type {
  confirmation_token
  reauthentication_token
  recovery_token
  email_change_token_new
  email_change_token_current
  phone_change_token

  @@schema("auth")
}

enum offer_status {
  active
  inactive

  @@schema("public")
}

enum user_role {
  student
  merchant_corporate
  merchant_branch
  admin

  @@schema("public")
}

enum verification_status {
  pending
  approved
  rejected
  expired

  @@schema("public")
}
