require 'pry'
require 'json'
require 'watir'
require 'nokogiri'
require_relative 'Accounts.rb'
require_relative 'Transactions.rb'


class FibankParser

	 def initialize()
        @accounts = []
        @transactions = []
        @browser = Watir::Browser.new :chrome
     end

      def browser(url)
        @browser.goto(url)
         while @browser.div(:id => "oCAPICOM").exists? do sleep 1 end
     end

     def login
        @browser.a(class: 'ng-binding').click
        @browser.a(id: 'demo-link').click
        @browser.element(:id => "step1").wait_until(&:present?)
     end

     def parsing
        @page = Nokogiri.HTML(@browser.html)
     end


   def account_info
    account_info = @page.css("#dashStep2 tr[id]")

      a_name = @page.css("#dashStep2 tr:nth-of-type(1) td:nth-of-type(1) span").text
      a_balance = @page.css("#dashStep2 tr:nth-of-type(1) td:nth-of-type(2) span").text
      a_currency = @page.css("#dashStep2 tr:nth-of-type(1) td:nth-of-type(3) span").text
      ai1 = Accounts.new(a_name, a_currency , a_balance, "USD")
      @accounts << ai1

  end




  def last_transaction
    transaction = @page.css("#step1 > td:nth-child(5) > div[class='cellText ng-scope'] > span")

      t_date = @page.css("#dashStep4 tr:nth-of-type(1) td:nth-of-type(2)").text
      t_description = @page.css("#dashStep4 tr:nth-of-type(1) td:nth-of-type(3)  p:nth-child(1)").text
      t_amount = @page.css("#dashStep4 tr:nth-of-type(1) td:nth-of-type(6) span").text
      t_name = @page.css("#dashStep4 tr:nth-of-type(1) td:nth-of-type(5) span").text
      lt = Transactions.new(t_date, t_description, t_amount, t_name)
      @transactions << lt
  end



  def put_transaction_in_account
    @accounts.each do |e|
      @transactions.each do |i|
        if(i.account_name == e.name)
          e.transactions << i
        end
      end
    end

    def hash_to_json
      @to_json = {"Accounts" => []}
      @accounts.each do |a|
        e_hash = Hash.new()
        e_hash["name"] = a.name
        e_hash["balance"] = a.balance
        e_hash["currency"] = a.currency
        e_hash["description"] = a.nature
        e_hash["transactions"] =[]

        a.transactions.each do |i|
          i_hash = Hash.new()
          i_hash["date"] = i.date
          i_hash["description"] = i.description
          i_hash["amount"] = i.amount

          e_hash["transactions"].push i_hash
        end
        @to_json["Accounts"].push e_hash
    end
end



     def Json(path)
	    File.open(path, "w") do |f|
		 	f.write(JSON.pretty_generate(@to_json))
	   end
	 end
  end

 class Runner
    parser = FibankParser.new
    parser.browser("https://my.fibank.bg/oauth2-server/login?client_id=E_BANK")
    parser.login
    parser.parsing
    parser.account_info
    parser.last_transaction
    parser.put_transaction_in_account
    parser.hash_to_json
    parser.Json('../Test_parser/Account.json')
    puts 'Parsed success! Good job!)'
 end
end