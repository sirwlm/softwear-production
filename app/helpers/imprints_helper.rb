module ImprintsHelper

  def imprint_order_link(imprint)
    if imprint.order.blank?
      return imprint.order_name
    else 
      return link_to imprint.order_name, order_path(imprint.order)
    end
  end

  def imprint_edit_order_link(imprint)
    unless imprint.order.blank?
      return bootstrap_edit_button(imprint.order)
    end
  end
end
