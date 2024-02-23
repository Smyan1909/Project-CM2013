function sanitizeEDFs(baseDir)
    filesindir = dir("*.edf")

    for i = 1:length(filesindir)
        filename = filesindir(i).name
        %[filepath, filestem, fileext] = fileparts(filename)

        if ~contains(filename, "_mod")
            % Copy file and name it with _mod

            newfilename = filename + "_mod.edf"
            %disp(newfilename)
            [success, msg, msgid] = copyfile(filename, newfilename)

            if success ~= 0
                error(msg)
            end

            % Now the proper sanitization part

            fid = fopen(newfilename, "r+")
            fseekStatus = fseek(fid, 168, "bof")
            %disp(fread(fid, 8, "uint8"))
            %disp(sprintf("fseek format is %d", fseekStatus))
            fwrite(fid, '11.11.11') % arbitrary date to substitute 00.00.00 which is considered invalid
            fclose(fid)
        end
    end