class Dashboard::Mailer < ApplicationMailer
  layout 'mailer'

  def forward(proposal)
    @proposal = proposal
    mail to: proposal.author.email, subject: proposal.title
  end

  def new_actions_notification(proposal, new_actions)
    @proposal = proposal
    @new_actions = new_actions
    mail to: proposal.author.email, subject: I18n.t("mailers.new_actions_notification.subject")
  end

  def new_actions_notification_on_create(proposal, new_actions)
    @proposal = proposal
    @new_actions = new_actions
    mail to: proposal.author.email, subject: I18n.t("mailers.new_actions_notification_on_create.subject")
  end
end
