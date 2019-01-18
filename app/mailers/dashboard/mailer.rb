class Dashboard::Mailer < ApplicationMailer
  layout 'mailer'

  def forward(proposal)
    @proposal = proposal
    mail to: proposal.author.email, subject: proposal.title
  end

  def new_actions_notification(proposal, new_actions)
    @proposal = proposal
    @new_actions = new_actions
    mail to: proposal.author.email, subject: proposal.title
  end
end
