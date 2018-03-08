function image_cell=data_extraction(filename)

    xmlData = xmlread(filename);
    import javax.xml.xpath.*

    factory = XPathFactory.newInstance;
    xpath = factory.newXPath;

    expr_xml = xpath.compile('annotation/object');
    nodeList_object = expr_xml.evaluate(xmlData, XPathConstants.NODESET);

    
    image_cell = cell(1,1);
    nc = 0;
    for i= 1: nodeList_object.getLength
        node_car = nodeList_object.item(i-1);
        expr_name = xpath.compile('name');
        nodeList_name = expr_name.evaluate(node_car, XPathConstants.NODE);
        name = nodeList_name.getFirstChild.getNodeValue;
        str_name = string(name);
        str_car = newline + "car" + newline;

        if strcmp(str_name, str_car)
            %node_polygon = nodeList_object.item(i-1);
            expr_object = xpath.compile('polygon');
            nodeList_polygon = expr_object.evaluate(node_car, XPathConstants.NODESET);
            car_cell = int16.empty(0,4);
            for k = 1:nodeList_polygon.getLength
                node_pt = nodeList_polygon.item(k-1);
                expr_polygon = xpath.compile('pt');
                nodeList_pt = expr_polygon.evaluate(node_pt, XPathConstants.NODESET);

                node_cell = cell(1,2);
                for l = 1: nodeList_pt.getLength
                    node_x = nodeList_pt.item(l-1);
                    expr_pt_x = xpath.compile('x');
                    expr_pt_y = xpath.compile('y');
                    nodelist_x = expr_pt_x.evaluate(node_x, XPathConstants.NODE);
                    nodelist_y = expr_pt_y.evaluate(node_x, XPathConstants.NODE);
                    %nodelist_x.getLength
                    char_x = char(nodelist_x.getFirstChild.getNodeValue);
                    num_x = str2num(char_x);
                    char_y = char(nodelist_y.getFirstChild.getNodeValue);
                    num_y = str2num(char_y);

                    node_cell{1,1} = [node_cell{1,1}, num_x];
                    node_cell{1,2} = [node_cell{1,2}, num_y];
                end
            x = min(node_cell{1,1});
            y = min(node_cell{1,2});
            w = max(node_cell{1,1}) - x;
            h = max(node_cell{1,2}) - y;
            car_cell = [x y w h];
            nc = nc + 1;
            end
        image_cell{1,1} = [image_cell{1,1}, car_cell];
        end
    end
    image_cell = cell2mat(image_cell);
    image_cell = reshape(image_cell, 4, nc);
    image_cell = image_cell.';
end