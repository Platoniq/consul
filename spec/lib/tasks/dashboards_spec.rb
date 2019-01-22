require 'rails_helper'
require 'rake'

describe 'Dashboards Rake' do

  describe '#send_notifications' do

    before do
      Rake.application.rake_require "tasks/dashboards"
      Rake::Task.define_task(:environment)
    end

    let :run_rake_task do
      Rake.application.invoke_task 'dashboards:send_notifications'
    end

    describe 'Not send notifications to proposal author when there are not news actions' do

      context 'for published proposals' do

        it 'when there are not news actions' do
        end

      end

      context 'for draft proposals' do

        it 'when there are not news actions' do
        end

      end
    end

    describe 'Send notifications to proposal author when there are news actions' do

      context 'for published proposals' do

        it 'because proposal has received a new vote' do
        end

        it 'because day_offset field is valid for today' do
        end

      end

      context 'for draft proposals' do

        it 'because proposal has received a new vote' do
        end

        it 'because day_offset field is valid for today' do
        end

      end
    end

  end

end
