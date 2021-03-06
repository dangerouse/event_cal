require 'event_cal/event'

class BirthdayEvent < ::EventCal::Event
  def self.all
    user = User.where(:user_name => 'shin1ohno').first_or_create
    user.update_attributes(:birth_day => Date.parse('1979-02-18'))

    events = []
    (user.birth_day.year .. Date.today.year + 10).each do |year|
      event = self.new(Date.parse("#{year}-#{user.birth_day.month}-#{user.birth_day.day}"))
      event.name = user.user_name
      events << event
    end

    events
  end
end
