module Hiptest
  class SignatureDiffer
    def self.diff(old, current)
      SignatureDiffer.new(old, current).compute_diff
    end

    def initialize(old, current)
      @old = old
      @current = current
    end

    def compute_diff
      @old_uid = map_by_uid(@old)
      @current_uid = map_by_uid(@current)

      compute_created
      compute_deleted
      compute_renamed
      compute_signature_changed

      diff = {}
      diff[:created] = @created unless @created.empty?
      diff[:deleted] = @deleted unless @deleted.empty?
      diff[:renamed] = @renamed unless @renamed.empty?
      diff[:signature_changed] = @signature_changed unless @signature_changed.empty?

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
      @renamed = @current_uid.map do |uid, aw|
        next if @created_uids.include?(uid) || @deleted_uids.include?(uid)
        next if @old_uid[uid]['name'] == aw['name']

        {name: @old_uid[uid]['name'], new_name: aw['name'], node: aw['node']}
      end.compact
    end

    def compute_signature_changed
      @signature_changed = @current_uid.map do |uid, aw|
        next if @created_uids.include?(uid) || @deleted_uids.include?(uid)
        next if @old_uid[uid]['parameters'] == aw['parameters']

        {name: aw['name'], node: aw['node']}
      end.compact
    end

    def map_by_uid(actionwords)
      Hash[actionwords.collect { |aw| [aw['uid'], aw] }]
    end
  end
end