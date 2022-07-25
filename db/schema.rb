# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_12_150257) do

  create_table "atom_feed_reads", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.text "title", null: false
    t.datetime "avalon_last_updated", null: false
    t.string "json_url", null: false
    t.string "avalon_item_url", null: false
    t.string "avalon_id", null: false
    t.boolean "successfully_read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "json_failed", default: false
    t.text "json_error_message"
    t.text "entry_xml"
    t.index ["avalon_id"], name: "index_atom_feed_reads_on_avalon_id", unique: true
  end

  create_table "avalon_item_notes", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "avalon_item_id", null: false
    t.text "text"
    t.string "creator", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "avalon_item_people", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "avalon_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "avalon_item_works", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "avalon_item_id"
    t.bigint "work_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "avalon_items", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.text "title", null: false
    t.string "avalon_id", null: false
    t.text "json", size: :medium, null: false
    t.string "pod_unit", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "needs_review"
    t.boolean "reviewed"
    t.bigint "current_access_determination_id"
    t.integer "review_state", default: 0, null: false
    t.boolean "modified_in_mco", default: false
    t.text "collection"
    t.boolean "reason_ethical_privacy_considerations"
    t.boolean "reason_licensing_restriction"
    t.boolean "reason_feature_film"
    t.boolean "reason_in_copyright"
    t.boolean "reason_public_domain"
    t.boolean "reason_license"
    t.boolean "reason_iu_owned_produced"
    t.boolean "structure_modified"
    t.index ["avalon_id"], name: "index_avalon_items_on_avalon_id", unique: true
  end

  create_table "contracts", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "date_edtf_text"
    t.date "end_date"
    t.string "contract_type"
    t.text "notes"
    t.boolean "perpetual"
    t.integer "avalon_item_id"
  end

  create_table "delayed_jobs", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "iu_affiliations", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nationalities", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "nationality"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "past_access_decisions", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "avalon_item_id"
    t.string "decision"
    t.string "changed_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "copyright_librarian", default: false
  end

  create_table "people", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "date_of_birth_edtf"
    t.string "date_of_death_edtf"
    t.string "place_of_birth"
    t.string "authority_source"
    t.string "aka"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "authority_source_url"
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.date "date_of_death"
    t.string "middle_name"
    t.boolean "entity"
    t.text "company_name"
    t.text "entity_nationality"
  end

  create_table "performance_contributor_people", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "performance_id"
    t.bigint "person_id"
    t.bigint "role_id"
    t.bigint "contract_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "performance_notes", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "performance_id", null: false
    t.text "text"
    t.string "creator", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "performances", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "work_id"
    t.string "location"
    t.date "performance_date"
    t.string "notes"
    t.string "access_determination"
    t.integer "copyright_end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "performance_date_string"
    t.string "title"
    t.string "in_copyright"
  end

  create_table "person_iu_affiliations", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "person_id"
    t.integer "iu_affiliation_id"
    t.integer "begin_date"
    t.integer "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "person_nationalities", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "nationality_id"
    t.date "begin_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pod_objects", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pod_physical_objects", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pod_pulls", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "pull_timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pod_workflow_statuses", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "policies", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "begin_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recording_contributor_people", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "contract_id"
    t.bigint "recording_id"
    t.bigint "role_id"
    t.bigint "person_id"
    t.bigint "policy_id"
    t.boolean "relationship_to_depositor"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "recording_depositor"
    t.boolean "recording_producer"
  end

  create_table "recording_notes", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "recording_id", null: false
    t.text "text"
    t.string "creator", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recording_performances", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "recording_id"
    t.bigint "performance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recording_take_down_notices", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "recording_id"
    t.bigint "take_down_notice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recordings", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.date "creation_date"
    t.boolean "published"
    t.date "date_of_first_publication"
    t.string "country_of_first_publication"
    t.boolean "receipt_of_will_before_90_days_of_death"
    t.boolean "iu_produced_recording"
    t.integer "creation_end_date"
    t.string "format"
    t.bigint "mdpi_barcode"
    t.string "authority_source"
    t.string "access_determination"
    t.string "in_copyright", default: ""
    t.date "copyright_end_date"
    t.text "decision_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "catalog_key"
    t.boolean "commercial"
    t.string "fedora_item_id"
    t.boolean "needs_review", default: false
    t.string "last_updated_by"
    t.string "unit", null: false
    t.bigint "atom_feed_read_id"
    t.bigint "avalon_item_id"
    t.text "authority_source_url"
    t.string "copyright_end_date_text"
    t.string "date_of_first_publication_text"
    t.string "creation_date_text"
    t.index ["avalon_item_id"], name: "index_recordings_on_avalon_item_id"
  end

  create_table "review_comments", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "avalon_item_id"
    t.string "creator", null: false
    t.boolean "copyright_librarian"
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "take_down_notices", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "track_contributor_people", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "track_id"
    t.bigint "person_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "contributor"
    t.boolean "principle_creator"
    t.boolean "interviewer"
    t.boolean "performer"
    t.boolean "conductor"
    t.boolean "interviewee"
  end

  create_table "track_works", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "track_id"
    t.bigint "work_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tracks", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "performance_id", null: false
    t.string "track_name", null: false
    t.integer "recording_start_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "recording_end_time"
    t.date "copyright_end_date"
    t.string "access_determination"
    t.string "in_copyright"
    t.string "copyright_end_date_text"
  end

  create_table "users", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.boolean "ignore_ads", default: false
    t.boolean "b_aaai"
    t.boolean "b_aaamc"
    t.boolean "b_afrist"
    t.boolean "b_alf"
    t.boolean "b_anth"
    t.boolean "b_archives"
    t.boolean "b_astr"
    t.boolean "b_athbaskm"
    t.boolean "b_athbaskw"
    t.boolean "b_athfhockey"
    t.boolean "b_athftbl"
    t.boolean "b_athrowing"
    t.boolean "b_athsoccm"
    t.boolean "b_athsoftb"
    t.boolean "b_athtennm"
    t.boolean "b_athvideo"
    t.boolean "b_athvollw"
    t.boolean "b_atm"
    t.boolean "b_bcc"
    t.boolean "b_bfca"
    t.boolean "b_busspea"
    t.boolean "b_cac"
    t.boolean "b_cdel"
    t.boolean "b_cedir"
    t.boolean "b_celcar"
    t.boolean "b_celtie"
    t.boolean "b_ceus"
    t.boolean "b_chem"
    t.boolean "b_cisab"
    t.boolean "b_clacs"
    t.boolean "b_cmcl"
    t.boolean "b_creole"
    t.boolean "b_cshm"
    t.boolean "b_cyclotrn"
    t.boolean "b_easc"
    t.boolean "b_educ"
    t.boolean "b_eppley"
    t.boolean "b_facility"
    t.boolean "b_finearts"
    t.boolean "b_folkethno"
    t.boolean "b_franklin"
    t.boolean "b_gbl"
    t.boolean "b_geology"
    t.boolean "b_glbtsssl"
    t.boolean "b_gleim"
    t.boolean "b_global"
    t.boolean "b_hper"
    t.boolean "b_ias"
    t.boolean "b_iaunrc"
    t.boolean "b_iprc"
    t.boolean "b_iuam"
    t.boolean "b_iulmia"
    t.boolean "b_jourschl"
    t.boolean "b_kinsey"
    t.boolean "b_lacasa"
    t.boolean "b_law"
    t.boolean "b_liberia"
    t.boolean "b_lifesci"
    t.boolean "b_lilly"
    t.boolean "b_ling"
    t.boolean "b_mathers"
    t.boolean "b_mdp"
    t.boolean "b_musbands"
    t.boolean "b_music"
    t.boolean "b_musopera"
    t.boolean "b_musrec"
    t.boolean "b_oid"
    t.boolean "b_optmschl"
    t.boolean "b_optomtry"
    t.boolean "b_polish"
    t.boolean "b_psych"
    t.boolean "b_recsports"
    t.boolean "b_reei"
    t.boolean "b_rtvs"
    t.boolean "b_sage"
    t.boolean "b_savail"
    t.boolean "b_swain"
    t.boolean "b_tai"
    t.boolean "b_thtr"
    t.boolean "b_undrwatr"
    t.boolean "b_univcomm"
    t.boolean "b_wells"
    t.boolean "b_west"
    t.boolean "ea_archives"
    t.boolean "ea_athl"
    t.boolean "i_archives"
    t.boolean "i_dent"
    t.boolean "i_libr_sca"
    t.boolean "i_raybrad"
    t.boolean "ko_archives"
    t.boolean "nw_archives"
    t.boolean "sb_archives"
    t.boolean "sb_phys"
    t.boolean "sb_ulib"
    t.boolean "se_archives"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "work_contributor_people", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "work_id"
    t.bigint "person_id"
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "principle_creator"
    t.boolean "contributor"
  end

  create_table "works", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "traditional"
    t.string "contemporary_work_in_copyright"
    t.string "restored_copyright"
    t.text "alternative_titles"
    t.string "publication_date_edtf"
    t.string "authority_source"
    t.text "notes"
    t.string "access_determination"
    t.string "copyright_end_date_edtf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "authority_source_url"
    t.date "publication_date"
    t.date "copyright_end_date"
    t.string "copyright_renewed"
  end

end
