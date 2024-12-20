classdef AnimalEnum < uint8
    %ANIMALENUM Summary of this class goes here
    %   Detailed explanation goes here

    enumeration
        Bear (0)
        Elk (1)
        Salmon (2)
        Hawk (3)
        Fox (4)
        NumAnimals (5)
    end

    methods (Static)
        function animal = initial2Animal(initial)
            fields = enumeration('AnimalEnum');
            i = 1; animalFound = false;
            while i <= length(fields) && ~animalFound
                currField = char(fields(i));
                if  currField(1) == initial
                    animalFound = true;
                    animal = fields(i);
                end
                i = i + 1;
            end
        end
    end

    methods
        function color = getColor(obj)
            switch obj
                case AnimalEnum.Bear
                    color = ColorEnum.Brown;
                case AnimalEnum.Elk
                    color = ColorEnum.LightBrown;
                case AnimalEnum.Salmon
                    color = ColorEnum.Pink;
                case AnimalEnum.Hawk
                    color = ColorEnum.LightBlue;
                case AnimalEnum.Fox
                    color = ColorEnum.Orange;
                otherwise
                    color = ColorEnum.Black;
            end
        end
    end
end

