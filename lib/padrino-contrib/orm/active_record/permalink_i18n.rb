module Padrino
  module Contrib
    module Orm
      module ActiveRecord
        ##
        # This module extend ActiveRecord.
        #
        # You need to to your model a column called +:permalink+
        #
        # then use +has_i18n_permalink :title like:
        #
        #   class Page < ActiveRecord::Base
        #     has_i18n_permalink :page, :langs => [:en, :fr, :de]
        #   end
        #
        module PermalinkI18n
          module ClassMethods
            def has_i18n_permalink(field, options={})
              include InstanceMethods
              @@_i18n_permalink_field = field
              @@_i18n_permalink_langs = options.delete(:langs)
              before_save :generate_i18n_permalinks
              i18n_permalink_langs.each do |lang|
                validates_uniqueness_of :"#{field}_#{lang}", options
              end
            end

            def i18n_permalink_for(name)
              require 'iconv' unless defined?(Iconv)
              name = Iconv.iconv('ascii//translit//IGNORE', 'utf-8', name).to_s
              name.gsub!(/\W+/, ' ') # non-words to space
              name.strip!
              name.downcase!
              name.gsub!(/\s+/, '-') # all spaces to dashes
              name
            end

            def i18n_permalink_field
              @@_i18n_permalink_field
            end

            def i18n_permalink_langs
              @@_i18n_permalink_langs
            end
          end

          module InstanceMethods
            def to_param
              permalink
            end

            protected
              def generate_i18n_permalinks
                singleton_class.i18n_permalink_langs.each do |lang|
                  self.send(:"permalink_#{lang}=", singleton_class.i18n_permalink_for(read_attribute(:"#{singleton_class.i18n_permalink_field}_#{lang}")))
                end
              end
          end # InstanceMethods
        end # PemalinkI18n
      end # ActiveRecord
    end # Orm
  end # Contrib
end # Padrino
::ActiveRecord::Base.extend(Padrino::Contrib::Orm::ActiveRecord::PermalinkI18n::ClassMethods)
