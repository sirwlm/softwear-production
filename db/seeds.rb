# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#

# seed default user
pw = 'pw4Admin'
email = 'admin@softwearcrm.com'
exists = !User.where(email: email).empty?
deleted_exists = !User.where(email: email).empty?
unless deleted_exists || exists
  admin_user = User.new(email: email,
                          first_name: 'Richard', last_name: 'Ross',
                          password: pw,
                          password_confirmation: pw,
                          admin: true)
  admin_user.confirm!
  puts 'Created admin bawss HUGH!' if admin_user.save
end

peon = User.new(email: 'test@softwearcrm.com',
                first_name: 'Peasant', last_name: 'McPleb',
                password: 'imahugenewbhelp',
                password_confirmation: 'imahugenewbhelp')
peon.confirm!
puts 'Created a scrubload user, laugh at him' if peon.save


m1 = Machine.create(name: 'Challenger')
m2 = Machine.create(name: 'Diamondback')
m3 = Machine.create(name: 'Chameleon')

o = Order.create(softwear_crm_id: 1)
j = Job.create(softwear_crm_id: 1, order_id: o.id)
Imprint.create(name: 'Imprint Name Goes Here', description: 'This is a description of an imprint', softwear_crm_id: 1, job_id: j.id, machine_id: m1.id, scheduled_at: Time.now, estimated_time: 1.5)
Imprint.create(name: 'Another Imprint Name Goes Here', description: 'This is the description of an imprint', softwear_crm_id: 1, job_id: j.id, machine_id: m2.id, scheduled_at: Time.now + 1.day, estimated_time: 2)
Imprint.create(name: 'Imprint Name', description: 'This is another description of an imprint', softwear_crm_id: 1, job_id: j.id, machine_id: m3.id, scheduled_at: Time.now + 2.days, estimated_time: 4)

