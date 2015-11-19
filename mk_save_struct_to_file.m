%% Function that saves struct object to file 
%  Input:
%    struct_name - name of the struct object
%    mode - 'csv' XOR 'txt'
%        alternative:    if ~isempty(strfind(b,'.txt')) == 1
%  Output:
%    file named
%        <caller_name>_LOG_<date>.<extension(depends on mode used)>
%    is touched ( created / appended (if called second time) )
%%
function mk_save_struct_to_file(struct_name, mode)
    % extract fields and values
        fields = repmat(fieldnames(struct_name), numel(struct_name), 1);
        values = struct2cell(struct_name);
    % convert all numericals to strings
        idx = cellfun(@isnumeric, values);
        values(idx) = cellfun(@num2str, values(idx), 'UniformOutput', 0);
    % write
        mk_stack = dbstack; % caller info
        output_file_name = [mk_stack(2).name ' -- LOG -- ' datestr(now,'yyyy-mm-dd--HH-MM-SS') '.' mode];
        fid = fopen(output_file_name, 'a');    
        if strcmp(mode, 'csv') == 1
            C = {fields{:}, values{:}};
            fmt_str = repmat('%s,', 1, size(C, 2));
            fprintf(fid, [fmt_str(1:end-1), '\n'], C{:});
        elseif strcmp(mode, 'txt') == 1
            fields_max = max(cellfun(@length,fields));
            for i = 1:length(fields)
                    fprintf(fid, '%s:\t\t\t\t%s\n', [fields{i}     repmat(' ', 1, fields_max - cellfun(@length,fields(i)))], values{i});
            end
        else
            error('MK: Wrong ''mode'' chosen.')
        end
        fclose(fid);
    %







