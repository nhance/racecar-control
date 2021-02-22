# driver name, event name, registered_cars: { car_number:, team_name: }, notifications_enabled:
object @event_detail

node(:driver_name) { |event_detail| event_detail.driver.full_name }
node(:event_name)  { |event_detail| event_detail.event.try(:name) }

child(@event_detail.registered_cars) do
  attributes :team_name, :number
end

child(@event_detail.event.try(:urls)) do
  attributes :name, :url
end

node(:notifications_enabled) { |event_detail| event_detail.driver.notifications_enabled? }
