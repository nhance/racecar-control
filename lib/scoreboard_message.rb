class ScoreboardMessage
  @@registry = {}

  MESSAGE_COMMANDS = {
    '$A' => "ScoreboardMessage::A",
    '$B' => "ScoreboardMessage::B",
    '$COMP' => "ScoreboardMessage::Comp",
    '$C' => "ScoreboardMessage::C",
    '$E' => "ScoreboardMessage::E",
    '$F' => "ScoreboardMessage::F",
    '$G' => "ScoreboardMessage::G",
    '$H' => "ScoreboardMessage::H",
    '$I' => "ScoreboardMessage::I",
    '$J' => "ScoreboardMessage::J"
  }

  attr_reader :command, :message

  def self.parse(raw_message)
    new(raw_message).reclassify
  end

  def self.registry
    @@registry
  end

  def reclassify
    if MESSAGE_COMMANDS.has_key?(command)
      MESSAGE_COMMANDS[command].constantize.new(@message)
    else
      self
    end
  end

  def initialize(raw_message = '')
    @message = raw_message.to_s.chomp
    map_message_to_fields
  end

  def blank?
    @message.blank?
  end

  def a?
    command == '$A'
  end

  def b?
    command == '$B'
  end

  def comp?
    command == '$COMP'
  end

  def c?
    command == '$C'
  end

  def e?
    command == '$E'
  end

  def j?
    command == '$J'
  end

  def h?
    command == '$H'
  end

  def f?
    command == '$F'
  end

  def g?
    command == '$G'
  end

  def to_s
    attributes = ScoreboardMessage.registry[self.class]
    fields = attributes.map do |field|
      value = send(field[:name])
      if field[:escaped]
        value = "\"#{value}\""
      end

      value
    end

    "#{fields.join(",")}\r\n"
  end

  private

  def map_message_to_fields
    parts = @message.split(",")
    field_data = ScoreboardMessage.registry[self.class]
    field_data.each do |field|
      value = parts.shift
      value.gsub!(/"/, '') if field[:escaped] && !value.nil?
      send("#{field[:name]}=", value)
    end
  end

  def self.fields(*instance_var_names)
    attributes = []

    instance_var_names.each_with_index do |instance_var_name, position|
      if instance_var_name.is_a?(Symbol)
        escaped = false
      else
        escaped = true
      end

      attr_accessor instance_var_name
      attributes[position.to_i] = { name: "#{instance_var_name}", escaped: escaped }
    end

    ScoreboardMessage.registry[self] = attributes
  end

  fields :command
end
