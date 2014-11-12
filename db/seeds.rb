# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#

m1 = Machine.create(name: 'Challenger')
m2 = Machine.create(name: 'Diamondback')
m3 = Machine.create(name: 'Chameleon')

o = Order.create(softwear_crm_id: 1)
j = Job.create(softwear_crm_id: 1, order_id: o.id)
Imprint.create(softwear_crm_id: 1, job_id: j.id, machine_id: m1.id, scheduled_at: Time.now, estimated_time: 158)
Imprint.create(softwear_crm_id: 1, job_id: j.id, machine_id: m2.id, scheduled_at: Time.now + 1.day, estimated_time: 76)
Imprint.create(softwear_crm_id: 1, job_id: j.id, machine_id: m3.id, scheduled_at: Time.now + 2.days, estimated_time: 253)

