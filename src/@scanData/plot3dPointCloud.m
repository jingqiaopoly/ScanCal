function success = plot3dPointCloud(obj, subsampling)
        % PLOT3DPOINTCLOUD plot the two point clouds from face 1 and
        % face 2 within a 3d plot with two different colors and shapes
        % face1: .
        % face2: *
        %
        %     success = plot3dPointCloud(obj,subsampling);
        %
        % Input:
        %    subsampling    (optional) defines every which point is
        %                   drawn [default: 100]
        % Output:
        %    success         1: the drawing was successfull
        %                    0: there was an error, while plotting
        %--------------------------------------------------------------

        % Check input
        if nargin < 2
            subsampling = 100;
        end

        figure(3);
        clf;
        for i=1:obj.nSet %
            if(obj.meta(i).face12(1)==1)

                pts_pl1 = obj.data(1,i).pts*0.001;

                hold on;
                scatter3(pts_pl1(1,1:subsampling:end),...
                    pts_pl1(2,1:subsampling:end),...
                    pts_pl1(3,1:subsampling:end),'.'); %,'b.'
            end
            if(obj.meta(i).face12(2)==1)
                pts_pl2 = obj.data(2,i).pts*0.001;

                hold on;
                scatter3(pts_pl2(1,1:subsampling:end),...
                    pts_pl2(2,1:subsampling:end),...
                    pts_pl2(3,1:subsampling:end),'.'); %,'b.'
            end
        end
        
%         figure(30);clf;
%        for i=1:obj.m_nSet %
%            pts=[];
%             if(obj.m_r.m_meta_data(i).face12(1)==1)
%                 pts = obj.m_data(1,i).m_pts*0.001;
%             end
%             if(obj.m_r.m_meta_data(i).face12(2)==1)
%                 pts_pl2 = obj.m_data(2,i).m_pts*0.001;
% 
%                 pts = [pts pts_pl2];
%                 
%                 pts = pts(:,pts(1,:)>17.45&pts(1,:)<17.85);
%                 pts = pts(:,pts(2,:)>5.35&pts(2,:)<5.7);
%                 pts = pts(:,pts(3,:)>2.85&pts(3,:)<3.1);
%                 hold on;
%                 scatter3(pts(1,1:subsampling:end),...
%                     pts(2,1:subsampling:end),...
%                     pts(3,1:subsampling:end),'.'); %,'b.'
%             end
%        end
        
        axis equal
        grid on;
        title('3D Point Cloud');
        xlabel('X (m)') 
        ylabel('Y (m)')
        zlabel('Z (m)')
    

        success = true;
    end