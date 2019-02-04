namespace :dashboards do

  desc "Send to user notifications from new actions availability on dashboard"
  task send_notifications: :environment do
    Proposal.not_archived.each do |proposal|
      dashboard_actions = Dashboard::Action.active

      actions_for_today = calculate_actions(dashboard_actions, proposal, Date.today)
      actions_for_yesterday = calculate_actions(dashboard_actions, proposal, Date.yesterday)

      if actions_for_today.count != actions_for_yesterday.count
        new_actions = actions_for_today - actions_for_yesterday
        Dashboard::Mailer.new_actions_notification(proposal, new_actions).deliver_later
      end
    end
  end

  def calculate_actions(dashboard_actions, proposal, date)
    published_at = proposal.published_at&.to_date
    proposal_votes = calculate_votes(proposal, date)
    published_at_or_today = published_at || Date.today
    day_offset = (date - published_at_or_today).to_i

    actions_for_today = dashboard_actions
                          .where('required_supports <= ?', proposal_votes)
                          .where('day_offset <= ?', day_offset)
                          .by_draft(proposal.draft?)
  end

  def calculate_votes(proposal, date)
    if date == Date.today
      proposal.cached_votes_up
    else
      Vote.where(votable: proposal).where('created_at <= ?', date).count
    end
  end
end
