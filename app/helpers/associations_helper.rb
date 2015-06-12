module AssociationsHelper
  def add_record_button(f, association, options = {}, &block)
    new_object = f.object.send(association).klass.new
    fields = f.fields_for(association, new_object, child_index: '__index__', class: 'piss piss piss') do |ff|
      render "#{association.to_s.singularize}_fields", f: ff
    end

    if block_given?
      link_text = capture(&block)
      options.delete(:text)
    else
      link_text = options.delete(:text) || "Add #{association.to_s.singularize}"
    end
    link_id = "add-fields-#{new_object.__id__}"
    link_classes = merge_classes('add-record-btn btn btn-primary', options.delete(:class))

    link_to(link_text, '#', id: link_id, class: link_classes) +
    javascript_tag(render('shared/add_record_button.js', element_id: link_id, fields: fields))
  end

  def remove_record_button(f, options = {}, &block)
    link_id = "rmv-fields-#{f.object.__id__}"
    if f.object.persisted?
      js = render 'shared/remove_persisted_record_button.js', element_id: link_id
    else
      js = render 'shared/remove_new_record_button.js', element_id: link_id
    end
    if block_given?
      link_text = capture(&block)
      options.delete(:text)
    else
      link_text = options.delete(:text) || "Remove #{f.object.class.name.underscore.humanize}"
    end
    link_classes = merge_classes('rmv-record-btn btn btn-danger', options.delete(:class))

    link_to(link_text, '#', id: link_id, class: link_classes) + javascript_tag(js)
  end

  ::ActionView::Helpers::FormBuilder.class_eval do
    def add_record_button(association, options = {}, &block)
      @template.add_record_button(self, association, options, &block)
    end

    def remove_record_button(options = {}, &block)
      @template.remove_record_button(self, options, &block)
    end
  end

  private

  def merge_classes(classes, other_classes)
    return classes if other_classes.nil?
    [classes, other_classes].join(' ')
  end
end
