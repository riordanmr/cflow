-- adddeposits.lua - script to identify and sum the large deposits into a UWCU account.
-- Sample input:
-- "0098828601","CK",8/26/2021,$3002.00,"Web Branch:TFR FROM CK 098828602","","Transfer",$4270.04,"", 
--
-- Usage:  lua adddeposits.lua <~/Downloads/Shared2010.csv

-- From http://lua-users.org/wiki/LuaCsv
-- Mark Riordan   2022-02-01

function ParseCSVLine (line,sep) 
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do 
		local c = string.sub(line,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(line,pos,pos) 
				if (c == '"') then txt = txt..'"' end 
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else	
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(line,sep,pos)
			if (startp) then 
				table.insert(res,string.sub(line,pos,startp-1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end 
		end
	end
	return res
end

function ProcessInput()
    local sum = 0.0
    while(true) do
        local line = io.stdin:read()
        if line then
            local vals = ParseCSVLine(line)
            local date = vals[3]
            if date == '1/31/2020' then
                break
            end
        
            local amt = vals[4]
            if string.sub(amt,1,1)=='$' then
                -- This is a positive number, indicating a deposit.
                amt = string.sub(amt, 2)
                amt = amt + 0
                if amt > 500 then
                    print('Deposit: ', amt,'on',date)
                    sum = sum + amt
                end
            else
                --print('  Withdrawl: ', amt)
            end
        else
            break
        end
    end
    print('Sum:', sum)
end

ProcessInput()
