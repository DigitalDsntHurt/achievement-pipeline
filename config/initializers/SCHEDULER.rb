

scheduler = Rufus::Scheduler.new

key = ENV["TRELLO_API_KEY"]
token = ENV["TRELLO_API_TOKEN"]


scheduler.in '5s' do
#scheduler.cron '5 5 * * *' do

	p key
	p token

	use_date = ""
	date = Date.today#.next_day

	if date.day.to_s.length == 1
		use_date += "#{date.year}-#{date.month}-0#{date.day}"
	elsif date.month.to_s.length == 1
		use_date += "#{date.year}-0#{date.month}-#{date.day}"
	else
		use_date += "#{date.year}-#{date.month}-#{date.day}"
	end


	Trello::Client.new do |client|
	  # Set API key
	  client.api_key = key
	  # Set token
	  client.api_token = token

	  # Get member with boards
	  do_board = ""
	  client.member( 'me', :boards => 'all' ) do |m|
	    m.boards.each do |b|
	      do_board += b['id'] if b['name'] == "do"
	  	end
	  end 

	  # Get board with lists
	  lists = {}
	  client.board( do_board, :lists => 'all' ) do |b|
	    b.lists.each do |l|
	      if l['name'] == "wealth"
	      	lists[l['name']] = l['id']
	      elsif l['name'] == "health"
	      	lists[l['name']] = l['id']
	      elsif l['name'] == "slp"
	      	lists[l['name']] = l['id']
	      elsif l['name'] == "create"
	      	lists[l['name']] = l['id']
	      elsif l['name'] == "meta / self / challenges"
	      	lists[l['name']] = l['id']
	      else
	      	#
	      end

	    end
	  end


	  email_string = "<h1>#{use_date}</h1><hr>"

	  ordered_lists = [ lists.select{|k,v| k == "health"}, lists.select{|k,v| k == "wealth"}, lists.select{|k,v| k == "slp"}, lists.select{|k,v| k == "create"}, lists.select{|k,v| k == "meta / self / challenges"} ]
	  ordered_lists.each{ |ol|
		client.list( ol.values[0], :cards => 'all' ) do |l|
		    email_string += "<h2><strong>#{l['name']}</strong></h2>"
		    email_string += "<ul>"
		    l.cards.each do |c|
		      if c['due'][0..9] == use_date
			    next if c['closed']
			    email_string += "<li><a href='#{c['url']}'>#{c['name']}</a></li>"
			  end
		    end
			email_string += "</ul>"
		end
	  }

		mail = Mail.new do
			from     'digitaldoesnthurt@gmail.com'
			to       'digitaldoesnthurt@gmail.com'
			subject  "Trello briefing for #{use_date}"
			html_part do
				content_type 'text/html; charset=UTF-8'
				body email_string
			end
		end

		mail.delivery_method :sendmail
		mail.deliver


	end #TRELLO::CLIENT


end #SCHEDULER


