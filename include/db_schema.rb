class MailBud::DbSchema
  SCHEMA = {
    :tables => {
      :accounts => {
        :columns => [
          {:name => "id", :type => :int, :autoincr => true, :primarykey => true},
          {:name => "host", :type => :varchar},
          {:name => "port", :type => :int},
          {:name => "username", :type => :varchar},
          {:name => "password", :type => :varchar},
          {:name => "folders", :type => :text},
          {:name => "ssl", :type => :enum, :maxlength => "'0','1'", :default => "0"},
          {:name => "protocol", :type => :enum, :maxlength => "'pop3','imap'"}
        ]
      },
      :options => {
        :columns => [
          {:name => "id", :type => :int, :autoincr => true, :primarykey => true},
          {:name => "title", :type => :varchar},
          {:name => "value", :type => :text}
        ],
        :indexes => [
          :title
        ]
      }
    }
  }
end
