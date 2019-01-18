namespace :dashboards do

  desc "Send to user notifications from new actions availability on dashboard"
  task send_notifications: :environment do
    Proposal.where("published_at is not null").each do |proposal|
      dashboard_actions = proposal.dashboard_actions
      active_actions_for_yesterday = dashboard_actions.active
                                      .where('required_supports <= ?', proposal.cached_votes_up)
                                      .where('day_offset <= ?', (Date.yesterday - published_at).to_i)
      active_actions_for_today = dashboard_actions.active
                                  .where('required_supports <= ?', proposal.cached_votes_up)
                                  .where('day_offset <= ?', (Date.today - published_at).to_i)
      if active_actions_for_today.count != active_actions_for_yesterday.count
        new_actions = active_actions_for_today - active_actions_for_yesterday
        Dashboard::Mailer.new_actions_notification(proposal, new_actions).deliver_later
      end
    end
  end
end
