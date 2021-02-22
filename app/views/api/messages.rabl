# { messages: [
#     { id: 1,
#       title: 'October 26, 2016 10:33AM',
#       message: 'Example message text.',
#       read_at: nil
#     }
#   ]
# }

collection @messages, root: 'messages', object_root: false
attributes :id, :title, :message, :read_at, :sent_at
