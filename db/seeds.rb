# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#

m1 = Machine.create(name: 'Challenger')
Machine.create(name: 'Diamondback')
Machine.create(name: 'Chameleon')

o = Order.create(softwear_crm_id: 1)
j = Job.create(softwear_crm_id: 1, order_id: o.id)
Imprint.create(softwear_crm_id: 1, job_id: j.id, machine_id: m1.id)
Imprint.create(softwear_crm_id: 1, job_id: j.id, machine_id: m2.id)

