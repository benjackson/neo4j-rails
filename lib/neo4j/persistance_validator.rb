class PersistedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, "must be saved beforehand") unless value.respond_to?(:persisted?) && value.persisted?
  end
end