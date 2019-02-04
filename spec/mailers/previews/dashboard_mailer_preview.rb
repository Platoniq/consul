class DashboardMailerPreview < ActionMailer::Preview
  def forward
    proposal = Proposal.first
    Dashboard::Mailer.forward(proposal)
  end

  # http://localhost:3000/rails/mailers/dashboard_mailer/new_actions_notification
  def new_actions_notification
    proposal = Proposal.first
    new_actions = Dashboard::Action.limit(1)
    Dashboard::Mailer.new_actions_notification(proposal, new_actions)
  end
end
