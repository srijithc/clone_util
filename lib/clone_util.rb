module ActiveRecord
  class Base
    def self.deep_clone_options(options={})                           
      class_eval do
        
        @clone_options = options

        def self.allow_dup
          @clone_options[:allow_dup]
        end
        
        def self.clone_info    
          @clone_options
        end
        
        def self.clone_associations
          @clone_options[:associations]
        end
        
        def self.equivalent_associations
          @clone_options[:equivalent_associations]
        end
        
        def self.unequal_attrs
          unequal_attrs = ['id']
          unequal_attrs.concat(@clone_options[:unequal_attributes]) if @clone_options[:unequal_attributes]
          unequal_attrs
        end
        
        def self.ignore_attributes
          ignore_attributes = ['created_at', 'updated_at', 'created_by_id', 'updated_by_id']
          ignore_attributes << @clone_options[:parent_id_attr].first if @clone_options[:parent_id_attr]
          ignore_attributes
        end
        
        def self.parent_id_attr
          @clone_options[:parent_id_attr]
        end
        
        def deep_clone
          recursive_clone
        end
        
        #TODO Should be private/protected
        def recursive_clone(parent_object_id   = nil,
            clone_id_hash      = {} )

          self.transaction do
            cloned_object = dup

            unequal_attrs = self.class.clone_info[:unequal_attributes] || []
            unequal_attrs.each do |a|
              cloned_object.send("#{a.to_s}=", nil)
            end
              
            #Set parent object_id
            if self.class.parent_id_attr and parent_object_id
              cloned_object.send("#{self.class.parent_id_attr[0].to_s}=", parent_object_id)
            end

            begin
              obj_attrs = cloned_object.attributes.clone
              self.class.ignore_attributes.each { |a| obj_attrs.delete(a.to_s)}
              if self.class.parent_id_attr and parent_object_id
                obj_attrs["#{self.class.parent_id_attr[0].to_s}"] = parent_object_id
              end
                 
              cloned_object.save!
              clone_id_hash["#{self.class.table_name}_#{self.id}"] = cloned_object.id
            rescue Exception  => e
              logger.info("deepclone: Clone save failed for " + cloned_object.inspect)
              raise e
            end

            add_cloned_associations(cloned_object, clone_id_hash)
            add_equivalent_associations(cloned_object, clone_id_hash)
                        
            clone_id_hash["#{self.class.table_name}_#{self.id}"] = cloned_object.id
            cloned_object
          end # transaction
        end # recursive_clone

        def add_equivalent_associations(cloned_object, clone_id_hash)
          if self.class.equivalent_associations
            self.class.equivalent_associations.each do |association|
              assocn = self.class.reflect_on_association(association)
              assocn_table_name = eval(assocn.class_name).table_name
              assocn_id = send(assocn.foreign_key)
              if assocn_id and (equivalent_id = clone_id_hash["#{assocn_table_name}_#{assocn_id}"])
                cloned_object.send("#{assocn.foreign_key}=", equivalent_id)
              end
            end
            cloned_object.save!
          end
        end

        def add_cloned_associations(cloned_object, clone_id_hash)
          if self.class.clone_associations
            self.class.clone_associations.each do |association|
              assocn = self.class.reflect_on_association(association)
              if assocn.macro == :has_many
                send(association).each do |obj|
                  c_obj = obj.respond_to?('deep_clone') ? obj.recursive_clone(cloned_object.id, clone_id_hash) : obj.dup
                  cloned_object.send(association) << c_obj unless c_obj.nil?
                end
              elsif assocn.macro == :has_and_belongs_to_many
                cloned_object.send("#{association.to_s}=", send(association))
              elsif (assocn.macro == :belongs_to) or (assocn.macro == :has_one)
                source_obj = send(association)
                unless source_obj.nil?
                  c_obj = source_obj.respond_to?('deep_clone') ? source_obj.recursive_clone(cloned_object.id, clone_id_hash) : source_obj.dup
                  cloned_object.send("#{association.to_s}=", c_obj) unless c_obj.nil?
                end
              end
            end
          end
        end
        
      end # class_eval
    end # deep_clone_options
  end # Base
end