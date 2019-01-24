

function result = getMagnitude( input )

    if( ~isfloat( input ) )
        input = single( input );
    end
    result = sqrt( input( :, :, 1 ).^2 + input( :, :, 2 ).^2 );
        
end
