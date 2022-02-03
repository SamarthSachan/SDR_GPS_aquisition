classdef gps
    %   all functions
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods (Static)
        
        function [CA_Code_Table] = CaTable()
            CA_Code_Table = ones(32,16368);%sampling frequency is given
            for i = 1:32
                CA_Code_Table(i,:) = gps.change(gps.code_generator(i,16));
            end
        end
        
        
        
        function [PRN_code] = code_generator(PRN_number,Sampling_frequency)
            % PRN number and intializing other variables
            shift_register1 = ones(1,10);
            shift_register2 = ones(1,10);
            PRN_code = ones(1,1023*Sampling_frequency); %intializing our final PRN code
            j=1; % PRN_code filling pointer
            for i = 1:1023
                b = gps.poly1(shift_register1); %calculating the bit to be inserted in 1st place
                b_last = shift_register1(10);
                %shifting array elements right
                for n = 10:-1:2
                    shift_register1(n) = shift_register1(n-1);
                end
                shift_register1(1) = b;
                %calculating the bit to be inserted and the output bit specific for PRN number
                [b , o] = gps.poly2(shift_register2 ,PRN_number );
                for n = 10:-1:2  %shifting array elements right
                    shift_register2(n) = shift_register2(n-1);
                end
                shift_register2(1) = b;
                
                for n=1:Sampling_frequency
                    PRN_code(j) = xor(o,b_last);
                    j=j+1;
                end
            end
            
        end
        
        function b = poly1(shift_register)
            b = mod((shift_register(3) + shift_register(10)),2);
        end
        
        function [b,o] = poly2(shift_register, PRN_number)
            SV = [2 6;3 7;4 8;5 9;1 9;2 10;1 8;2 9;3 10;2 3;3 4;5 6;6 7;7 8;8 9;9 10;1 4;2 5;3 6;4 7;5 8;6 9;1 3;4 6;5 7;6 8;7 9;8 10;1 6;2 7;3 8;4 9];
            o = xor(shift_register(SV(PRN_number,1)),shift_register(SV(PRN_number,2))) ;
            b = mod((shift_register(2) + shift_register(3) + shift_register(6) + shift_register(8) + shift_register(9) + shift_register(10)),2);
        end
        
        function [arr] = circular_corr(PRN_code)
            s = size(PRN_code);
            arr = zeros(s(2),s(2));
            for i = 1:s(2)
                for j = 1:s(2)
                    arr(i , j) = PRN_code(j);
                end
                PRN_code=circshift(PRN_code,1);
            end
        end
        
        function [arr] = change(PRN_code)
            c =size(PRN_code);
            for i = 1:c(1,2)
                if PRN_code(i)==0
                    PRN_code(i)=-1;
                end
            end
            arr = PRN_code;
        end
        
    end
end

