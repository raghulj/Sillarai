class Notifier < ActionMailer::Base
  
  def contact_details(name,email,comment,web)
    recipients "raghulj@gmail.com"
    from email
    subject " Comments for Sillarai"
    sent_on Time.now
    body name +"\n"+comment +"\n"+web
  end


  def forgot_password(mail,login,newpass)
    recipients mail
    from "admin@sillarai.com"
    subject "New password for your sillarai account"
    sent_on Time.now
    body "Hi #{login},\n The new password for sillarai.com is #{newpass} . Please change your password once you login.\n Regards,\nAdmin."
  end

  def welcome_message(mail)
    recipients mail
    from "admin@sillarai.com"
    subject "Welcome to Sillarai"
    sent_on Time.now
    str = ""
    str += "\nThank you for registering with sillarai.com . \n\n your email address for login: #{mail}\n\n"
    str += " We are delighted to have you in sillarai.com. Please login and start tracking your everyday expenses.\n"
    str += " We will also be grateful if you partcipate in usage survey. This helps us to know how the money is scattered around.\n"
    str += " We respect your privacy and ensure that by agreeing to participate in usage survey, We will only use the expense details without knowing to whom the money belongs to. To participate in usage survey, please tick the usage survey check box in preference page once you login.\n"
    str += "If you are not interested in that, We wont collect your data. You can track your day to day expenses asusual. You can download the mobile version of the sillarai application from github.  We are continously working on sillarai to make your tracking of expenses more easier.\n"
    str += "\nThank you.\n Administrator."
    body str
  end

end
