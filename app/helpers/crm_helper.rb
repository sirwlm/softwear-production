module CrmHelper
  def crm_image_tag(path, options = {})
    image_tag "#{path}", options
  end

  def proof_status_panel(proof)
    case proof.status
    when 'Pending'          then 'panel-warning'
    when 'Emailed Customer' then 'panel-warning'
    when 'Approved'         then 'panel-success'
    when 'Rejected'         then 'panel-danger'
    else
      'panel-default'
    end
  end
end
