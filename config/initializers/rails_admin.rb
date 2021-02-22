RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end

  ## == Cancan ==
  config.authorize_with :cancan
  config.current_user_method &:current_user

  ## == PaperTrail ==
  #config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0
  config.audit_with :paper_trail, 'Driver', 'PaperTrail::Version' # PaperTrail >= 3.0.0
  config.audit_with :paper_trail, 'Car', 'PaperTrail::Version' # PaperTrail >= 3.0.0
  config.audit_with :paper_trail, 'Scan', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  config.navigation_static_links = {
    "Driver List" => '/drivers',
    "API apps" => '/oauth/applications'
  }

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    history_index
    history_show
    # import
  end
end
