ActiveAdmin.register User do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

#  is_verified            :boolean          default(FALSE)
#  coin                   :integer


  permit_params :is_verified

  form do |f|
    f.inputs 'Details' do

      f.input :is_verified, as: :boolean

    end

    f.actions
  end

end
