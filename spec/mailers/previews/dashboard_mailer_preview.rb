class DashboardMailerPreview < ActionMailer::Preview
  def forward
    proposal = Proposal.first
    Dashboard::Mailer.forward(proposal)
  end

  # http://localhost:3000/rails/mailers/dashboard_mailer/new_actions_notification_rake_published
  def new_actions_notification_rake_published
    proposal = Proposal.where(published: true).first
    new_actions_ids = Dashboard::Action.limit(1).id
    Dashboard::Mailer.new_actions_notification(proposal, [new_actions_ids])
  end

  # http://localhost:3000/rails/mailers/dashboard_mailer/new_actions_notification_rake_created
  def new_actions_notification_rake_created
    proposal = Proposal.where(published: false).first
    new_actions_ids = Dashboard::Action.limit(1).id
    Dashboard::Mailer.new_actions_notification(proposal, [new_actions_ids])
  end

  # http://localhost:3000/rails/mailers/dashboard_mailer/new_actions_notification_on_create
  def new_actions_notification_on_create
    proposal = Proposal.first
    Dashboard::Mailer.new_actions_notification_on_create(proposal)
  end
end
