function R = eul2rotm(eul,convention)
% Warning: This is only a overwrite function of the same function of the Robotics
% System Toolbox. It does not cover the full functionality.
    if nargin < 2
        convention = 'ZYX';
    end

    if ~strcmpi(convention,'zyx')
        error(['The function is currently only implemented for the "ZYX" convention. '...
            'Use the Robotics System Toolbox instead, if you want to use other ' ...
            'conventions.']);
    end
    RZ=[cos(eul(1)), -sin(eul(1)), 0; sin(eul(1)), cos(eul(1)), 0; 0, 0, 1];
    RY=[cos(eul(2)), 0, sin(eul(2)); 0, 1, 0; -sin(eul(2)), 0, cos(eul(2))];
    RX=[1, 0, 0; 0, cos(eul(3)), -sin(eul(3)); 0, sin(eul(3)), cos(eul(3))];
    R = RZ*RY*RX;
end