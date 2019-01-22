namespace :dashboards do

  desc "Send to user notifications from new actions availability on dashboard"
  task send_notifications: :environment do
    Proposal.not_archived.each do |proposal|
      dashboard_actions = Dashboard::Action.active
      published_at = proposal.published_at&.to_date

      #Actions status for today
      proposal_votes_for_today = proposal.cached_votes_up
      published_at_or_today = published_at || Date.today
      actions_for_today = dashboard_actions
                            .where('required_supports <= ?', proposal_votes_for_today)
                            .where('day_offset <= ?', (Date.today - published_at_or_today).to_i)
                            .by_draft(proposal.draft?)

      #Actions status for yesterday
      proposal_votes_for_yesterday = Vote.where(votable: proposal)
                                         .where('created_at <= ?', Date.yesterday).count
      published_at_or_yesterday = published_at || Date.yesterday
      actions_for_yesterday = dashboard_actions
                                .where('required_supports <= ?', proposal_votes_for_yesterday)
                                .where('day_offset <= ?', (Date.yesterday - published_at_or_yesterday).to_i)
                                .by_draft(proposal.draft?)

      if actions_for_today.count != actions_for_yesterday.count
        new_actions = actions_for_today - actions_for_yesterday
        Dashboard::Mailer.new_actions_notification(proposal, new_actions).deliver_later
      end
    end
  end
end
