module CrmHelper
  def crm_image_tag(path, options = {})
    image_tag "#{path}", options
  end

  def proof_status_panel(proof)
    case (proof.state rescue 'bad')
    when 'not_ready'                   then 'panel-warning'
    when 'pending_manager_approval'    then 'panel-warning'
    when 'pending_customer_submission' then 'panel-warning'
    when 'manager_rejected'            then 'panel-danger'
    when 'pending_customer_approval'   then 'panel-warning'
    when 'customer_approved'           then 'panel-success'
    when 'customer_rejected'           then 'panel-danger'

    when 'bad' then 'panel-danger'
    else
      'panel-default'
    end
  end
end
