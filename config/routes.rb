Rails.application.routes.draw do
  resources :avalon_items
  resources :avalon_item_notes, only: [:new, :create]
  resources :people
  resources :performances
  resources :performance_notes, only: [:new, :create]
  resources :policies
  resources :recording_contributors
  resources :recording_notes, only: [:new, :create]
  resources :recordings
  resources :tracks
  resources :contracts


  get '/nav/search', to: 'nav#search', as: "search"
  get '/date_search', to: 'nav#date_search_get', as: 'date_search_get'
  post '/date_search', to: 'nav#date_search_post', as: 'date_search_post'

  get '/nav/test', to: 'nav#test', as: 'nav_test'
  get '/user_guide', to: 'nav#user_guide', as: 'user_guide'
  get '/atom_tester/search', to: 'atom_feed_reader#search', as: 'atom_feed_search'

  get '/atom_tester', to: 'atom_feed_reader#index', as: 'atom_feed_tester'
  get '/atom_tester/prepopulate', to: 'atom_feed_reader#prepopulate', as: 'atom_feed_prepopulate'
  get '/atom_tester/read_current', to: 'atom_feed_reader#read_current', as: 'atom_feed_read_current'
  get '/atom_tester/json/:id', to: 'atom_feed_reader#read_json', as: 'atom_feed_read_json'
  get '/atom_tester/load_avalon_record/:id', to: 'atom_feed_reader#load_avalon_record', as: 'load_avalon_record'

  get '/people/new/entity/', to: 'people#new_entity', as: 'new_entity'

  # # specify single barcode
  # post '/services/access_decision_by_barcode/:mdpi_barcode', to: 'services#access_decision_by_barcode', as: 'access_decision_by_barcode'
  # # specify json array of barcodes in request body
  # post '/services/access_decision_by_barcodes', to: 'services#access_decision_by_barcodes', as: 'access_decision_by_barcodes'
  # get '/services/access_decision_by_fedora_id/:fid', to: 'services#access_decision_by_fedora_id', as: 'access_decision_by_fedora_id'
  # get '/services/access_decisions_by_barcodes', to: 'services#access_decisions_by_barcodes', as: 'access_decisions_by_barcodes'
  # get '/services/access_decisions_by_fedora_ids', to: 'services#access_decisions_by_fedora_ids', as: 'access_decisions_by_fedora_ids'
  get '/services/access_decisions_tester', to: 'test#test_access_decisions', as: 'test_access_decisions'
  get '/services/access_determination/:avalon_identifier', to: 'services#access_determination', as: 'access_determination'

  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/signoutg', to: 'sessions#destroy', via: :get

  resources :sessions, only: [:new, :destroy] do
    get :validate_login, on: :collection
  end

  get '/users/', to: 'user#index', as: 'users'
  get '/user/ldap_lookup', to: 'user#ldap_lookup', as: 'ldap_lookup'

  resources :works

  # ajax calls
  # get '/avalon_items/:id/rmd_metadata', to: 'avalon_items#ajax_rmd_metadata', as: 'ajax_avalon_item_rmd_metadata'
  post '/avalon_items/access_decision', to: 'avalon_items#ajax_post_access_decision', as: 'ajax_avalon_item_access_decision'
  post '/avalon_items/ajax_needs_review', to: 'avalon_items#ajax_post_needs_review', as: 'ajax_post_needs_review'
  post '/avalon_items/ajax_reviewed', to: 'avalon_items#ajax_post_reviewed', as: 'ajax_post_reviewed'
  # get '/avalon_items/ajax/cm_all', to: 'avalon_items#ajax_all_cm_items', as: 'ajax_avalon_all_cm_items'
  # get '/avalon_items/ajax/cm_iu_default_only_items', to: 'avalon_items#ajax_cm_iu_default_only_items', as: 'avalon_items_cm_iu_default_only_items'
  # get '/avalon_items/ajax/cm_waiting_on_cl', to: 'avalon_items#ajax_cm_waiting_on_cl', as: 'avalon_items_cm_waiting_on_cl'
  # get '/avalon_items/ajax/cm_waiting_on_self', to: 'avalon_items#ajax_cm_waiting_on_self', as: 'avalon_items_cm_waiting_on_self'
  # get '/avalon_items/ajax/cm_access_determined', to: 'avalon_items#ajax_cm_access_determined', as: 'avalon_items_cm_access_determined'
  get '/avalon_items/ajax/calced_access_determination/:id', to: 'avalon_items#ajax_calced_access', as: 'ajax_avalon_item_calced_access'
  get '/avalon_items/cm/cm_all', to: 'avalon_items#cm_all_items', as: 'avalon_all_cm_items'
  get '/avalon_items/cm/cm_iu_default_only', to: 'avalon_items#cm_iu_default_only', as: 'avalon_items_cm_iu_default_only'
  get '/avalon_items/cm/cm_waiting_on_cl', to: 'avalon_items#cm_waiting_on_cl', as: 'avalon_items_cm_waiting_on_cl'
  get '/avalon_items/cm/cm_waiting_on_self', to: 'avalon_items#cm_waiting_on_self', as: 'avalon_items_cm_waiting_on_self'
  get '/avalon_items/cm/cm_access_determined', to: 'avalon_items#cm_access_determined', as: 'avalon_items_cm_access_determined'
  get '/avalon_items/cm/cm_published', to: 'avalon_items#cm_published', as: 'avalon_items_cm_published'

  # new person
  get '/avalon_items/:id/ajax_people_adder', to: 'avalon_items#ajax_people_adder', as: 'ajax_people_adder_get'
  post '/avalon_items/:id/ajax_people_adder', to: 'avalon_items#ajax_people_adder_post', as: 'ajax_people_adder_post'
  # existing person
  get '/avalon_items/:id/ajax_people_setter/:pid', to: 'avalon_items#ajax_people_setter', as: 'ajax_people_setter_get'
  post '/avalon_items/:id/ajax_people_setter/:pid', to: 'avalon_items#ajax_people_setter_post', as: 'ajax_people_setter_post'
  get '/avalon_items/:id/ajax_work_setter/:wid', to: 'avalon_items#ajax_work_setter', as: 'ajax_work_setter_get'
  post '/avalon_items/:id/ajax_work_setter/:wid', to: 'avalon_items#ajax_work_setter_post', as: 'ajax_work_setter_post'
  get '/ajax/people/ajax_work_person_form', to: "people#ajax_work_person_form", as: 'ajax_work_person_form'

  get '/avalon_items/:id/ajax_work_adder', to: 'avalon_items#ajax_work_adder', as: 'ajax_work_adder_get'
  post '/avalon_items/:id/ajax_work_adder', to: 'avalon_items#ajax_work_adder_post', as: 'ajax_work_adder_post'
  post 'avalon_items/:id/ajax_add_note', to: 'avalon_items#ajax_add_note', as: 'ajax_avalon_item_add_note'

  get '/avalon_items/ajax/cl_all', to: 'avalon_items#ajax_all_cl_items', as: 'ajax_avalon_cl_all'
  get '/avalon_items/ajax/cl_initial_review', to: 'avalon_items#ajax_cl_initial_review', as: 'avalon_items_cl_initial_review'
  get '/avalon_items/ajax/cl_waiting_on_cm', to: 'avalon_items#ajax_cl_waiting_on_cm', as: 'avalon_items_cl_waiting_on_cm'
  get '/avalon_items/ajax/cl_waiting_on_self', to: 'avalon_items#ajax_cl_waiting_on_self', as: 'avalon_items_cl_waiting_on_self'
  get '/avalon_items/ajax/cl_access_determined', to: 'avalon_items#ajax_cl_access_determined', as: 'avalon_items_cl_access_determined'

  get '/collections/', to: "collections#index", as: 'collections_index'
  post '/collections/', to: "collections#assign_access", as: 'collection_assign'
  get '/collection/', to: "collections#collection_list", as: "collection_list"

  get '/contracts/ajax/new/:ai_id', to: 'contracts#ajax_new', as: 'ajax_new_contract'
  post '/contracts/ajax/create', to: 'contracts#ajax_create', as: 'ajax_create_contract'
  get '/contracts/ajax/edit/:id', to: 'contracts#ajax_edit', as: 'ajax_edit_contract'
  post '/contracts/ajax/update', to: 'contracts#ajax_update', as: 'ajax_update_contract'
  get '/contracts/ajax/show/:id', to: 'contracts#ajax_show', as: 'ajax_show_contract'

  get 'recordings/ajax/edit/:id', to: 'recordings#ajax_edit', as: 'ajax_edit_recording'
  get 'recordings/ajax/show/:id', to: 'recordings#ajax_show', as: 'ajax_show_recording'


  get '/people/ajax/new', to: 'people#ajax_new_person', as: 'ajax_new_person'
  get '/people/ajax/autocomplete', to: 'people#ajax_autocomplete', as: 'people_ajax_autocomplete'
  get '/people/ajax/autocomplete_company', to: "people#ajax_autocomplete_company", as: "people_ajax_autocomplete_company"
  get '/people/ajax/edit/:id', to: 'people#ajax_edit_person', as: 'ajax_edit_person'

  get '/performances/ajax/new/:recording_id', to: 'performances#ajax_new_performance', as: 'ajax_new_performance'
  get '/performances/ajax/edit/:id', to: 'performances#ajax_edit_performance', as: 'ajax_edit_performance'
  get '/performances/ajax/show/:id', to: 'performances#ajax_show_performance', as: 'ajax_Show_performance'
  post '/performances/ajax/access_determination', to: 'performances#ajax_access_determination', as: 'ajax_performance_access_determination'

  get '/tracks/ajax/new/:performance_id', to: 'tracks#ajax_new_track', as: 'ajax_new_track'
  get '/tracks/ajax/edit/:track_id', to: 'tracks#ajax_edit_track', as: 'ajax_edit_track'
  post '/tracks/ajax/access_determination', to: 'tracks#ajax_access_determination', as: 'ajax_track_access_determination'

  post '/users/ajax/set_user_unit/:username/:unit/:access', to: 'user#ajax_set_user_unit', as: 'ajax_set_user_unit'
  post '/users/ajax/set_user_cl/:username', to: 'users#ajax_toggle_cl', as: 'ajax_set_user_cl'
  get '/works/ajax/new', to: 'works#ajax_new_work', as: 'ajax_new_work'
  get '/works/ajax/:id', to: 'works#ajax_show', as: 'ajax_show_work'
  get '/work/ajax/autocomplete_title', to: 'works#ajax_autocomplete_title', as: 'work_ajax_autocomplete_title'
  get '/work/ajax/edit/:id', to: 'works#ajax_edit_work', as: 'ajax_edit_work'

  root 'nav#start'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
