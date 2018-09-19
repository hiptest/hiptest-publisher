module Hiptest
  class SignatureDiffer
    def self.diff(old, current, library_name: nil)
      SignatureDiffer.new(old, current).compute_diff(library_name)
    end

    def initialize(old, current)
      @old = old
      @current = current
    end

    def compute_diff(library_name = nil)
      if library_name.nil?
        @old_uid = map_by_uid(@old)
        @current_uid = map_by_uid(@current)
      else
        @old_uid = map_by_uid(get_library_actionwords(@old, library_name))
        @current_uid = map_by_uid(get_library_actionwords(@current, library_name))
      end

      compute_created
      compute_deleted

      compute_definition_changed
      compute_signature_changed
      compute_renamed

      diff = {}
      diff[:created] = @created unless @created.empty?
      diff[:deleted] = @deleted unless @deleted.empty?
      diff[:renamed] = @renamed unless @renamed.empty?
      diff[:signature_changed] = @signature_changed unless @signature_changed.empty?
      diff[:definition_changed] = @definition_changed unless @definition_changed.empty?

      diff
    end

    private

    def compute_created
      @created_uids = @current_uid.keys - @old_uid.keys
      @created = @created_uids.map {|uid| {name: @current_uid[uid]['name'], node: @current_uid[uid]['node']}}
    end

    def compute_deleted
      @deleted_uids = @old_uid.keys - @current_uid.keys
      @deleted = @deleted_uids.map {|uid| {name: @old_uid[uid]['name']}}
    end

    def compute_renamed
      excluded = [
        @created_uids,
        @deleted_uids,
        @definition_changed_uids,
        @signature_changed_uids
      ].flatten.uniq

      @renamed = @current_uid.map do |uid, aw|
        next if excluded.include?(uid)
        next if @old_uid[uid]['name'] == aw['name']

        {name: @old_uid[uid]['name'], new_name: aw['name'], node: aw['node']}
      end.compact
    end

    def compute_signature_changed
      excluded = [
        @created_uids,
        @deleted_uids,
        @definition_changed_uids
      ].flatten.uniq

      @signature_changed_uids = []
      @signature_changed = @current_uid.map do |uid, aw|
        next if excluded.include?(uid)
        next if @old_uid[uid]['parameters'] == aw['parameters']

        @signature_changed_uids << uid
        {name: aw['name'], node: aw['node']}
      end.compact
    end

    def compute_definition_changed
      @definition_changed_uids = []

      @definition_changed = @current_uid.map do |uid, aw|
        next if @old_uid[uid].nil?
        next unless @old_uid[uid].has_key?('body_hash')
        next if aw['body_hash'] == @old_uid[uid]['body_hash']

        @definition_changed_uids << uid
        {name: aw['name'], node: aw['node']}
      end.compact
    end

    def get_library_actionwords(data, library_name)
      library = data.select {|item| item['type'] == 'library' && item['name'] == library_name}.first
      library.nil? ? [] : library['actionwords']
    end

    def map_by_uid(items)
      Hash[items.reject {|item| item['type'] == 'library'}.collect { |aw| [aw['uid'], aw] }]
    end
  end
end
