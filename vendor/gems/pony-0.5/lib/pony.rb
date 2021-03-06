require 'rubygems'
require 'net/smtp'
require 'mime/types'
begin
	require 'smtp_tls'
rescue LoadError
end
require 'base64'
begin
	require 'tmail'
rescue LoadError
	require 'actionmailer'
end

module Pony
	def self.mail(options)
		raise(ArgumentError, ":to is required") unless options[:to]

		via = options.delete(:via)
		if via.nil?
			transport build_tmail(options)
		else
			if via_options.include?(via.to_s)
				send("transport_via_#{via}", build_tmail(options), options)
			else
				raise(ArgumentError, ":via must be either smtp or sendmail")
			end
		end
	end

	def self.build_tmail(options)
		mail = TMail::Mail.new
		mail.content_type = options[:content_type] if options[:content_type]
		mail.to = options[:to]
		mail.cc = options[:cc] || ''
		mail.from = options[:from] || 'pony@unknown'
		mail.subject = options[:subject]
		if options[:attachments]
			# If message has attachment, then body must be sent as a message part
			# or it will not be interpreted correctly by client.
			body = TMail::Mail.new
			body.body = options[:body] || ""
			body.content_type = options[:content_type] || "text/plain"
			mail.parts.push body
			(options[:attachments] || []).each do |name, body|
				attachment = TMail::Mail.new
				attachment.transfer_encoding = "base64"
				attachment.body = Base64.encode64(body)
				content_type = MIME::Types.type_for(name).to_s
				attachment.content_type = content_type unless content_type == ""
				attachment.set_content_disposition "attachment", "filename" => name
				mail.parts.push attachment
			end
		else
			mail.content_type = options[:content_type] || "text/plain"
			mail.body = options[:body] || ""
		end
		mail
	end

	def self.sendmail_binary
		sendmail = `which sendmail`.chomp
		sendmail.empty? ? '/usr/sbin/sendmail' : sendmail
	end

	def self.transport(tmail)
		if File.executable? sendmail_binary
			transport_via_sendmail(tmail)
		else
			transport_via_smtp(tmail)
		end
	end

	def self.via_options
		%w(sendmail smtp)
	end

	def self.transport_via_sendmail(tmail, options={})
		IO.popen('-', 'w+') do |pipe|
			if pipe
				pipe.write(tmail.to_s)
			else
				exec(sendmail_binary, "-t")
			end
		end
	end

	def self.transport_via_smtp(tmail, options={:smtp => {}})
		default_options = {:smtp => { :host => 'localhost', :port => '25', :domain => 'localhost.localdomain' }}
		o = default_options[:smtp].merge(options[:smtp])
		smtp = Net::SMTP.new(o[:host], o[:port])
		if o[:tls]
			raise "You may need: gem install smtp_tls" unless smtp.respond_to?(:enable_starttls)
			smtp.enable_starttls
		end
		if o.include?(:auth)
			smtp.start(o[:domain], o[:user], o[:password], o[:auth])
		else
			smtp.start(o[:domain])
		end
		smtp.send_message tmail.to_s, tmail.from, tmail.to
		smtp.finish
	end
end
