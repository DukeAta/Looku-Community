ActiveAdmin.register Document do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :price, :document_type, :university, :institution, :country, :level, :year, :score, :is_verified, :category, :user_id
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

  batch_action :verify_all do |ids|
    Document.find(ids).each do |document|
      document.verified!
    end
    redirect_to collection_path, alert: "The documents have been verified."
  end

  form do |f|
    f.inputs 'Details' do
      f.input :title, as: :string , label: 'Title'
      f.input :price, type: 'integer'
      f.input :document_type, as: :string
      f.input :university, as: :string
      f.input :institution, as: :string
      f.input :country, as: :select, collection: Constants::DataConstantsHelper::COUNTRY.map { |key,value| [value, key] } 
      f.input :level, as: :string
      f.input :user
      f.input :year, type: 'integer'
      f.input :score, type: 'integer'
      f.input :is_verified, as: :boolean
      f.input :category, as: :select, collection: ['essay', 'dissertation']
    end
    f.actions
  end

end
