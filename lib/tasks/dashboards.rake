namespace :dashboards do

  desc "Send to user notifications from new actions availability on dashboard"
  task send_notifications: :environment do
    #Mejorar Where para tratar el minimo numero de propuestas
    Proposal.where("published_at is not null").each do |proposal|
      dashboard_actions = Dashboard::Action.active
      published_at = proposal.published_at&.to_date
      proposal_votes_for_yesterday = Vote.where(votable: proposal)
                                         .where('created_at <= ?', Date.yesterday).count

      actions_for_yesterday = dashboard_actions
                                .where('required_supports <= ?', proposal_votes_for_yesterday)
                                .where('day_offset <= ?', (Date.yesterday - published_at).to_i)
      actions_for_today = dashboard_actions
                            .where('required_supports <= ?', proposal.cached_votes_up)
                            .where('day_offset <= ?', (Date.today - published_at).to_i)

      if actions_for_today.count != actions_for_yesterday.count
        new_actions = actions_for_today - actions_for_yesterday
        debugger
        Dashboard::Mailer.new_actions_notification(proposal, new_actions).deliver_later
      end
    end
  end
end
