%% Programme doté d'une IHM permettant de commander l'analyseur de réseau Keysight
%% FieldFox et de verfier le fonctionnement de rack de duplication
            
%% Cadre : Stage Onera
%% Date : Décembre 2018
%% Auteur : Oscar Yung


classdef HF_FieldFox_v2 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        RUNButton                       matlab.ui.control.Button
        DbutMHzLabel                    matlab.ui.control.Label
        FreqStart                       matlab.ui.control.NumericEditField
        FinMHzLabel                     matlab.ui.control.Label
        FreqEnd                         matlab.ui.control.NumericEditField
        EmplacementdesauvegardeLabel    matlab.ui.control.Label
        Folder                          matlab.ui.control.EditField
        NombredepointsEditFieldLabel    matlab.ui.control.Label
        NbPoints                        matlab.ui.control.NumericEditField
        BandedefrquenceLabel            matlab.ui.control.Label
        ChoixmesureLabel                matlab.ui.control.Label
        Canal                           matlab.ui.control.ListBox
        NumroderackSpinnerLabel         matlab.ui.control.Label
        NumRack                         matlab.ui.control.Spinner
        NumrodevoieLabel                matlab.ui.control.Label
        NumSplit                        matlab.ui.control.Spinner
        NumrodesortieSpinnerLabel       matlab.ui.control.Label
        NumPath                         matlab.ui.control.Spinner
        Avertis                         matlab.ui.control.CheckBox
        IdentitappareilTextAreaLabel    matlab.ui.control.Label
        Identite                        matlab.ui.control.TextArea
        GainmaxdBEditFieldLabel         matlab.ui.control.Label
        GainMax                         matlab.ui.control.NumericEditField
        GainmindBEditFieldLabel         matlab.ui.control.Label
        GainMin                         matlab.ui.control.NumericEditField
        DphasagemaxEditFieldLabel       matlab.ui.control.Label
        DephasMax                       matlab.ui.control.NumericEditField
        DphasageminEditFieldLabel       matlab.ui.control.Label
        DephasMin                       matlab.ui.control.NumericEditField
        CorrespondanceDuplicateurLabel  matlab.ui.control.Label
        LimitesautorisesLabel           matlab.ui.control.Label
        ApplicationdemesuresLabel       matlab.ui.control.Label
        ListederreursTextAreaLabel      matlab.ui.control.Label
        Errors                          matlab.ui.control.TextArea
        DeltaGainmaxdBEditFieldLabel    matlab.ui.control.Label
        DeltaGainMax                    matlab.ui.control.NumericEditField
        DeltaDphasagemaxEditFieldLabel  matlab.ui.control.Label
        DeltaPhasMax                    matlab.ui.control.NumericEditField
        AdresseTextAreaLabel            matlab.ui.control.Label
        Adresse                         matlab.ui.control.TextArea
        RESETButton                     matlab.ui.control.Button
        TOUTCOMPARERButton              matlab.ui.control.Button
        PositionMarkerMHzEditFieldLabel  matlab.ui.control.Label
        Marker                          matlab.ui.control.NumericEditField
        NombrecyclemoyennageEditFieldLabel  matlab.ui.control.Label
        balayage                        matlab.ui.control.NumericEditField
    end

    methods (Access = private)

        % Button pushed function: RESETButton
        function RESETButtonPushed(app, event)
            % Connexion à l'appareil
            
            ip='192.168.113.206'; % adresse IP de l'analyseur
            
            app.Adresse.Value=ip; % affiche l'IP de l'analyseur sur l'interface
            
            
            RohdeZVA = tcpip(ip,5025); % créer un objet TCPIP
            
            fopen(RohdeZVA);           % se connecte
            
            fprintf(RohdeZVA,'*IDN?');    % Demande à l'instrument de renvoyer son identification
            
            myId = fscanf(RohdeZVA,'%c'); % Lit et enregistre sa réponse
            
            app.Identite.Value=myId;      % Affiche la réponse sur l'interface
            
            
            % Reset
            
            fprintf(RohdeZVA,'*RST');
            
            
            % Ferme la connexion
            
            fclose(RohdeZVA);
        end

        % Button pushed function: RUNButton
        function RUNButtonPushed(app, event)
     
            
            
            %                            %
            %                            %
            %                            %
            %                            %
            %  Connexion à l'appareil    %
            %      et configuration      %
            %                            %
            %                            %
            %                            %
            %                            %
            
            
            
            % Instantiation de la connexion de l'Analyseur Keysight via LAN en tant que Socket
            % Port 5025
            
            % Notons que le masque de sous réseau est 255.255.255.0
            % et l'ordinateur a comme adresse 192.168.113.100
            
            
            % Modifie l'adresse TCPIP pour correspondre à l'adresse IP de l'analyseur.
            
            
            
            ip='192.168.113.206'; % adresse IP de l'analyseur
            
            app.Adresse.Value=ip; % affiche l'IP de l'analyseur sur l'interface
            
            FieldFox = tcpip(ip,5025); % créer un objet TCPIP
            
            
            
            
            % Définit la taille d'entrée et de sortie du buffer
            
            set(FieldFox, 'InputBufferSize', 8096); % Taille en octets
            
            set(FieldFox, 'OutputBufferSize', 8069);
            
            
            
            % Ordre de lecture des données binaires BigEndian par défaut
            
            % Aboutit à des données corrompues, il faut litteEndian
            
            
            set(FieldFox,'ByteOrder', 'littleEndian'); % Modifie l'ordre de lecture
            
            
            
            
            % Ouvre l'object FieldFox défini plus haut, connexion à l'analyseur
            
            fopen(FieldFox);
            
            
            
            
            % Communication avec l'appareil et "requête"
            
            fprintf(FieldFox,'*IDN?\n');  % Demande à l'instrument de renvoyer son identification
            
            myId = fscanf(FieldFox,'%c'); % Lit et enregistre sa réponse
            
            app.Identite.Value=myId;      % Affiche la réponse sur l'interface
            
            
            
            
            
            % Nettoie le registre d'état et la liste d'erreurs avant de piloter l'instrument
            
            fprintf(FieldFox,'*CLS\n');
            
            
            % Vérifie si les erreurs ont été éffacées et si tout va bien
            % doit renvoyer '0, "No Error"
            
            fprintf(FieldFox,'SYST:ERR?\n');
            
            initErrCheck=fscanf(FieldFox,'%c')
            
            %app.Errors.Value=initErrCheck;
            
            
            
            % Paramètrisation de l'instrument
            
            % Instrument FieldFox en mode analyseur de réseau
            
            
            fprintf(FieldFox,'INST:SEL ''NA''');  % INST pour instrument
            
            % SEL pour selection
            % NA pour Network Analyzer
            
            
            % Désactive le déclenchement continu
            
            fprintf(FieldFox,'INIT:CONT OFF\n');
            
            
            % Récupère les fréquences de début et de fin selectionnées par l'utilisateur
            
            Debut=app.FreqStart.Value;
            Fin=app.FreqEnd.Value;
            
            % Définit la fréquence de début et la fréquence de fin
            
            fprintf(FieldFox,['FREQ:STAR ',num2str(Debut),'E6;STOP ',num2str(Fin),'E6\n']);
            
            
            % Définit le nombre de points
            
            fprintf(FieldFox,['SWE:POIN ',num2str(app.NbPoints.Value),'\n']);
            
            
            % Récupère le canal choisi par l'utilisateur : S11, S12, S22 ou S21
            
            Canal=app.Canal.Value;
            
            
            % Définit un nombre de cycle pour le moyennage
            
            balay=app.balayage.Value;
            
            
            
            fprintf(FieldFox,['AVER:COUN ',int2str(balay),'\n']);
            
            
            
            % Définit le canal de mesure puis le selectionne
            
            fprintf(FieldFox,'CALC:PAR1:DEF %s;SEL\n',Canal);
            
            
            
            
            
            % La requête *OPC? pause le programme jusqu'à la réalisation des commandes en attente
            
            fprintf(FieldFox,'*OPC?\n');
            
            done = fscanf(FieldFox,'%1d');
            
            
            %                            %
            %                            %
            %                            %
            %                            %
            %  Acquisition des données   %
            %                            %
            %                            %
            %                            %
            %                            %
            %                            %
            
            
            
            
            % Déclenchement du balayage et attend son achèvement
            
            % Pour de longs balayages, il faut augmenter la durée du time out du TCPIP
            
            
            fprintf(FieldFox,'INIT;*OPC?\n');
            
            trigComplete = fscanf(FieldFox,'%1d');
            
            % Attend la fin du balayage
            
            
            for i=1:balay
                query(FieldFox,'INIT:IMM;*OPC?\n');
            end
            
            
            
            
            % Selectionne le type de mesure, MLOG correspond à Log Magnitude, soit le gain en dB
            
            fprintf(FieldFox,'CALC:FORM MLOG\n');
            
            
            % Configuration du format des données demandées à l'instrument
            
            % Demande des nombres réelles sur 32 bits
            
            
            fprintf(FieldFox, 'FORM:DATA REAL,32\n');
            
            
            
            
            % Réinitialise le moyennage, permet de reprendre des mesures sans prendre en compte
            % les anciennes
            
            fprintf(FieldFox,'AVER:CLE\n');
            
            
            
            
            
            fprintf(FieldFox,'CALC:DATA:FDATA?\n'); % requête les données
            
            % Lit en enregistre les données (Gain) dans une variable
            
            myBinDataMag = binblockread(FieldFox,'float');
            
            
            % Une ligne n'est pas lue et reste en attente
            
            % Il faut la lire et vider le buffer
            
            % Sinon erreur "Query Interrupted Error"
            
            hangLineFeed = fread(FieldFox,1);
            
            
            
            
            % Récupération des valeurs de fréquences
            
            % Définit les données comme des réelles sur 64 bits pour
            
            % assurer la meilleur résolution
            
            
            fprintf(FieldFox, 'FORM:DATA REAL,64\n');
            
            
            
            % Réinitialise le moyennage
            
            fprintf(FieldFox,'AVER:CLE\n');
            
            
            
            
            % Demande les valeurs de fréquences
            
            fprintf(FieldFox,'SENS:FREQ:DATA?\n');
            
            % Récupère et enregistre les valeurs
            
            myBinStimulusData = binblockread(FieldFox,'double');
            
            
            
            % Une ligne reste non lue dans le buffer, il faut la lire
            
            hangLineFeed = fread(FieldFox,1);
            
            
            
            % Convertie les fréquences en MHz
            
            myStimulusDataMHz = myBinStimulusData/1E6;
            
            
            
            
            
            
            % Définit la phase comment mesurande
            
            fprintf(FieldFox, 'CALC:FORM PHAS\n');
            
            
            
            
            % Définit le format de données demandées, nombres réelles sur 32 bits
            
            
            fprintf(FieldFox, 'FORM:DATA REAL,32\n');
            
            % Requête, demande les valeurs
            
            fprintf(FieldFox,'CALC:DATA:FDATA?\n');
            
            % Récupère les données et les enregistre dans une variable
            
            myBinDataPhas = binblockread(FieldFox,'float');
            
            
            % Une ligne reste non lue dans le buffer, il faut la lire
            
            hangLineFeed = fread(FieldFox,1);
            
            
            % Active les markers
            
            
            if (Debut<app.Marker.Value||app.Marker.Value<Fin)
                Mark=true;
                fprintf(FieldFox, 'CALC:MARK1 NORM\n');
                %fprintf(FieldFox, 'CALC:MARK1:ACT\n');
                fprintf(FieldFox, 'CALC:MARK1:FORM MAGPhase\n');
                fprintf(FieldFox, ['CALC:MARK1:X ',num2str(app.Marker.Value),'e6\n']);
                Marker1=query(FieldFox,'CALC:MARK1:Y?\n')
                
            end
            
            
            
            
            
            % Créer une matrice de 3 colonnes avec x lignes
            % Contient les fréquences, les gains et les phases
            
            Data1=[myStimulusDataMHz,myBinDataMag,myBinDataPhas];
            
            
            
            
            %                            %
            %                            %
            %                            %
            %                            %
            %    Affichage graphique     %
            %        des mesures         %
            %                            %
            %                            %
            %                            %
            %                            %
            
            
            figure(1) % Constitué d'une ligne et de deux colonnes
            
            subplot(1,2,1) % Premier graphique
            
            clear title xlabel ylabel
            
            plot(myStimulusDataMHz, myBinDataMag) % Gain en fonction de la fréquence
            
            title([Canal,' Gain=f(fréq)'])
            
            xlabel('Fréquence (MHz)')
            
            ylabel ('Gain (dB)')
            
            
            subplot(1,2,2) % Deuxième graphique
            
            clear title xlabel ylabel
            
            plot(myStimulusDataMHz, myBinDataPhas)
            
            title([Canal,' Phase=f(fréq)'])
            
            xlabel('Frequence (MHz)')
            
            ylabel ('Phase (degré°)')
            
            
            %                            %
            %                            %
            %                            %
            %                            %
            %  Traitement des données    %
            %                            %
            %                            %
            %                            %
            %                            %
            %                            %
            
            % On vérifie si le splitter rempli les critères attendues
            
            etat='PASS'; % initialise l'etat de la mesure, respect des bornes
            
            % Récupère les limites de gain puis de phase définies par l'utilisateur
            
            lim_min_Mag=app.GainMin.Value;
            lim_max_Mag=app.GainMax.Value;
            
            lim_min_Phas=app.DephasMin.Value;
            lim_max_Phas=app.DephasMax.Value;
            
            % Récupère les valeurs maximales et minimales de gain puis de phase des mesures
            
            MaxMag=max(myBinDataMag);
            iMaxMag=find(myBinDataMag==max(myBinDataMag));
            iMaxMag=myStimulusDataMHz(iMaxMag);
            
            MinMag=min(myBinDataMag);
            iMinMag=find(myBinDataMag==min(myBinDataMag));
            iMinMag=myStimulusDataMHz(iMinMag);
            
            MaxPhas=max(myBinDataPhas);
            iMaxPhas=find(myBinDataPhas==max(myBinDataPhas));
            iMaxPhas=myStimulusDataMHz(iMaxPhas);
            
            MinPhas=min(myBinDataPhas);
            iMinPhas=find(myBinDataPhas==min(myBinDataPhas));
            iMinPhas=myStimulusDataMHz(iMinPhas);
            
            
            
            % Vérification du critère sur le gain
            % Si des valeurs sortent des bornes, change la variable etat
            % et ouvre une fenêtre d'erreur
            
            if(MaxMag>lim_max_Mag||MinMag<lim_min_Mag)
                etat='FAIL';
                if app.Avertis.Value
                    f=uifigure;
                    tarea=uitextarea(f);
                    tarea.Value='Attention : Gain hors des bornes'
                end
            end
            
            % Vérification du critère sur la phase
            % Si des valeurs sortent des bornes, change la variable etat
            % et ouvre une fenêtre d'erreur
            
            
            if(MaxPhas>lim_max_Phas||MinPhas<lim_min_Phas)
                etat='FAIL';
                if app.Avertis.Value
                    h=uifigure;
                    tarea=uitextarea(h);
                    tarea.Value='Attention : Phase hors des bornes'
                end
            end
            
            
            % Choix de l'emplacement de sauvegarde des mesures
            
            % Récupère les informations données par l'utilisateur
            
            % Exemple "Folder\Rack4\Voie8\Sortie82"
            
            
            RackFolder=['Rack',int2str(app.NumRack.Value)];
            
            SplitFolder=['Voie',int2str(app.NumSplit.Value)];
            
            PathFolder=['Sortie',int2str(app.NumSplit.Value),int2str(app.NumPath.Value)];
            
            
            
            % Emplacement de sauvegarde des mesures actuelles
            
            FoldName=fullfile(app.Folder.Value,RackFolder,SplitFolder,PathFolder);
            
            % Créer un dossier s'il nexiste pas déjà
            
            mkdir(FoldName)
            
            
            
            % Verifie l'existence de fichiers concernant cette mesure
            % dans le cas où déjà faite, incrémente le num de version
            
            ver=1; % initialise la version du fichier de mesures
            
            for j=1:15
                if exist(fullfile(FoldName,['Mesure_num',int2str(j),'_',Canal,'.csv']),'file')==2
                    ver=j+1;
                end
            end
            
            
            % Récupère le nom du fichier
            FileName=['Mesure_num',int2str(ver),'_',Canal,'.csv'];
            
            
            % NEW
            
            FoldName2=fullfile(app.Folder.Value,RackFolder,SplitFolder);
            
            
            % Si on mesure la sortie81 => on compare à sortie82 et inversement
            
            if app.NumPath.Value==1
                compare=['Sortie',int2str(app.NumSplit.Value),'2'];
            else
                compare=['Sortie',int2str(app.NumSplit.Value),'1'];
            end
            
            
            % Vérification de l'existence d'un tel fichier et de son utilité
            
            
            % Caractérise la légitimité de la compaison
            
            bool=false; % la comparaison n'est pas légitime : balayage différent
            
            
            % k la version du fichier que l'on cherche
            
            k=1; % initialisation
            
            
            % Emplacement du fichier que l'on cherche
            
            rep=fullfile(app.Folder.Value,RackFolder,SplitFolder,compare);
            
            
            
            % Cherche la version la plus récente,
            % suppose qu'il n'y ait pas plus que 15 fois la mesure
            
            % Variable caractérisant l'existance du fichier
            
            aut=false; % initialisation, il n'existe pas de fichier à comparer
            
            for i=1:15
                if exist(fullfile(rep,['Data_Test_',int2str(i),'_',Canal,'.mat']),'file')==2
                    aut=true; % il existe un fichier à comparer
                    k=i;
                end
            end
            
            
            % Si un fichier a été trouvé
            
            if aut==true
                
                % Emplacement du fichier
                comp=fullfile(app.Folder.Value,RackFolder,SplitFolder,compare,['Data_Test_',int2str(k),'_',Canal,'.mat']);
                % Charge le fichier et récupère les variables, dont Data2
                load(comp)
                
                % Si les fréquences des deux mesures sont identiques
                if Data1(:,1)==Data2(:,1)
                    
                    % Récupère les valeurs extrêmes et leur indice du gain puis de phase
                    
                    MaxMag2=max(Data2(:,2));
                    iMaxMag2=find(Data2(:,2)==(max(Data2(:,2))));
                    iMaxMag2=Data1(iMaxMag2,1);
                    
                    MinMag2=min(Data2(:,2));
                    iMinMag2=find(Data2(:,2)==(min(Data2(:,2))));
                    iMinMag2=Data1(iMinMag2,1);
                    
                    MaxPhas2=max(Data2(:,3));
                    iMaxPhas2=find(Data2(:,3)==(max(Data2(:,3))));
                    iMaxPhas2=Data1(iMaxPhas2,1);
                    
                    MinPhas2=min(Data2(:,3));
                    iMinPhas2=find(Data2(:,3)==(min(Data2(:,3))));
                    iMinPhas2=Data1(iMinPhas2,1);
                    
                    % Récupère la différence de gain et de phase entre les deux voies
                    % en fonction de la fréquence
                    
                    DeltaMag=Data1(:,2)-Data2(:,2);
                    DeltaMagMax=max(abs(DeltaMag));
                    DeltaPhas=Data1(:,3)-Data2(:,3);
                    DeltaPhasMax=max(abs(DeltaPhas));
                    
                    % Comparaison légitime
                    bool=true;
                    
                end
            end
            
            % Définit un format de temps, utile pour le nom des fichiers
            formatOut='yyyy-mm-dd_HH-MM';
            dt=datestr(now,formatOut);
            
            
            %                            %
            %                            %
            %                            %
            %                            %
            %    Affichage graphique     %
            %        des mesures         %
            %      des deux voies        %
            %                            %
            %                            %
            %                            %
            %                            %
            
            
            % Si un fichier utilisable a été trouvé, affiche des courbes
            
            if bool==true
                
                % Permet d'ouvrir la fenêtre de comparaison en grand
                set(figure(2),'Units','Normalized','Outerposition',[0 0 1 1]);
                
                
                % Mesure du gain, voie actuellement mesurée
                
                subplot(3,2,1)
                
                clear title xlabel ylabel
                
                plot(myStimulusDataMHz,Data1(:,2));
                
                line([Debut,Fin],[lim_min_Mag,lim_min_Mag],'Color','red','LineStyle','--')
                line([Debut,Fin],[lim_max_Mag,lim_max_Mag],'Color','red','LineStyle','--')
                
                title(['Mesure ',int2str(ver),' : Gain=f(fréq); ',PathFolder])
                
                %xlabel('Fréquence en MHz')
                
                ylabel ('Gain (dB)')
                
                
                
                
                % Mesure de phase, voie actuellement mesurée
                
                subplot(3,2,2)
                
                clear title xlabel ylabel
                
                plot(myStimulusDataMHz,Data1(:,3));
                
                line([Debut,Fin],[lim_min_Phas,lim_min_Phas],'Color','red','LineStyle','--')
                line([Debut,Fin],[lim_max_Phas,lim_max_Phas],'Color','red','LineStyle','--')
                
                title(['Mesure ',int2str(ver),' : Déphasage=f(fréq); ',PathFolder])
                
                %xlabel('Frequence en MHz')
                
                ylabel ('Phase (°)')
                
                
                
                % Mesure de gain, autre voie, précédemment mesurée
                
                subplot(3,2,3)
                
                clear title xlabel ylabel
                
                plot(myStimulusDataMHz,Data2(:,2));
                
                line([Debut,Fin],[lim_min_Mag,lim_min_Mag],'Color','red','LineStyle','--')
                line([Debut,Fin],[lim_max_Mag,lim_max_Mag],'Color','red','LineStyle','--')
                
                title(['Mesure ',int2str(k),' : Gain=f(fréq); ',compare])
                
                %xlabel('Fréquence en MHz')
                
                ylabel ('Gain (dB)')
                
                
                
                
                
                % Mesure de phase, autre voie, précédemment mesurée
                
                subplot(3,2,4)
                
                clear title xlabel ylabel
                
                plot(myStimulusDataMHz,Data2(:,3));
                
                line([Debut,Fin],[lim_min_Phas,lim_min_Phas],'Color','red','LineStyle','--')
                line([Debut,Fin],[lim_max_Phas,lim_max_Phas],'Color','red','LineStyle','--')
                
                title(['Mesure ',int2str(k),' : Déphasage=f(fréq); ',compare])
                
                %xlabel('Fréquence en MHz')
                
                ylabel ('Phase (°)')
                
                
                % Delta Gain Voie1 et Voie2
                subplot(3,2,5)
                
                clear title xlabel ylabel
                
                plot(myStimulusDataMHz,DeltaMag);
                
                line([Debut,Fin],[-app.DeltaGainMax.Value,-app.DeltaGainMax.Value],'Color','red','LineStyle','--')
                line([Debut,Fin],[+app.DeltaGainMax.Value,+app.DeltaGainMax.Value],'Color','red','LineStyle','--')
                
                title('DeltaGain=f(fréq)')
                
                xlabel('Fréquence (MHz)')
                
                ylabel('Delta Gain (dB)')
                
                
                % Delta Phase Voie1 et Voie2
                subplot(3,2,6)
                
                clear title xlabel ylabel
                
                plot(myStimulusDataMHz, DeltaPhas);
                
                line([Debut,Fin],[-app.DeltaPhasMax.Value,-app.DeltaPhasMax.Value],'Color','red','LineStyle','--')
                line([Debut,Fin],[+app.DeltaPhasMax.Value,+app.DeltaPhasMax.Value],'Color','red','LineStyle','--')
                
                title('DeltaPhase=f(fréq)')
                
                xlabel('Fréquence (MHz)')
                
                ylabel('DeltaPhase (°)')
                
                % Apparence
                
                suptitle(['Mesure ',Canal,' ',RackFolder,SplitFolder])
                
                % Enregistrement des courbes en format png
                
                FileName4=sprintf('Courbes_%s_%s.png',Canal,dt);
                saveas(figure(2),fullfile(FoldName2,FileName4));
                
            end
            
            
            %                            %
            %                            %
            %                            %
            %    Enregistrement des      %
            %    données et création     %
            %      d'un rapport          %
            %                            %
            %                            %
            %                            %
            %                            %
            
            % Enregistre les données de mesure dans un fichier csv
            
            f=fopen(fullfile(FoldName,FileName),'w');
            fprintf(f,'Fréquence en MHz; Gain en dB; Déphasage en degré\n');
            fprintf(f,'%f; %f; %f\n',transpose(Data1));
            fclose(f);
            
            % Enregistre les données de Data1 sous le nom Data2
            
            FileName2=sprintf('Data_Test_%s_%s.mat',int2str(ver),Canal);
            Data2=Data1;
            save(fullfile(FoldName,FileName2),'Data2');
            
            
            % Enregistre la position et valeurs du Marker
            
            
            
            if Mark==true
                
                MAGPhase=strsplit(Marker1,',');
                MAG=str2double(MAGPhase(1));
                Phase=str2double(MAGPhase(2));
                Markers={app.Marker.Value;MAG;Phase}
                FileName1=sprintf('Markers_%s_%s.mat',int2str(ver),Canal);
                save(fullfile(FoldName,FileName1),'Markers');
            end
            
            
            
            % Si comparaison légitime, prépare un rapport
            
            
            if bool
                
                FileName3=sprintf('Rapport_%s_%s_%s.html',Canal,etat,dt);
                h=fopen(fullfile(FoldName2,FileName3),'wt'); %wt sinon ne va pas à la ligne
                
                fprintf(h,'<!DOCTYPE html>\n');
                fprintf(h,'<html>\n');
                fprintf(h,'    <head>\n');
                fprintf(h,'        <meta charset="utf-8" />\n');
                fprintf(h,'        <title>Mesures Splitters</title>\n');
                fprintf(h,'    </head>\n');
                
                fprintf(h,'    <body>\n');
                
                fprintf(h,'    <h1>%s</h1>\n',etat); %FAIL OU PASS
                fprintf(h,'        <p><em>%s<em/><p/>\n',RackFolder);
                fprintf(h,'        <p><em>%s<em/><p/>\n',SplitFolder);
                
                fprintf(h,'        <p><em>%s<em/><br/>\n',PathFolder);
                fprintf(h,'        Gain min : %s dB @ %s MHz <br/>\n',MinMag,iMinMag);
                fprintf(h,'        Gain max : %s dB @ %s MHz <br/>\n',MaxMag,iMaxMag);
                fprintf(h,'        Phase min : %s degré @ %s MHz <br/>\n',MinPhas,iMinPhas);
                fprintf(h,'        Phase max : %s degré @ %s MHz <p/>\n',MaxPhas,iMaxPhas);
                
                fprintf(h,'        <p><em>Sortie :<em/> %s<br/>\n',compare);
                fprintf(h,'        Gain min : %s dB @ %s MHz <br/>\n',MinMag2,iMinMag2);
                fprintf(h,'        Gain max : %s dB @ %s MHz <br/>\n',MaxMag2,iMaxMag2);
                fprintf(h,'        Phase min : %s degré @ %s Mhz <br/>\n',MinPhas2,iMinPhas2);
                fprintf(h,'        Phase max : %s degré @ %s Mhz <p/>\n',MaxPhas2,iMaxPhas2);
                
                fprintf(h,'    </body>\n');
                fprintf(h,'</html>\n');
                
                fclose(h);
            end
            
            
            % Contrôle la liste d'erreurs
            
            % Si l'application fonctionne normalement et il n'y a pas d'erreur lors de la mesure
            
            % renvoie : '0, "No Error", sinon il y a une erreur
            
            
            
            fprintf(FieldFox, 'SYST:ERR?');
            
            finalErrCheck=fscanf(FieldFox, '%c')
            
            app.Errors.Value=finalErrCheck;
            
            
            % Ferme la connexion
            
            fclose(FieldFox);
        end

        % Button pushed function: TOUTCOMPARERButton
        function TOUTCOMPARERButtonPushed(app, event)
            RackFolder=['Rack',int2str(app.NumRack.Value)];
            
            SplitFolder=['Voie',int2str(app.NumSplit.Value)];
            
            PathFolder=['Sortie',int2str(app.NumSplit.Value),int2str(app.NumPath.Value)];
            
            FoldName=fullfile(app.Folder.Value,RackFolder,SplitFolder,PathFolder);
            
            valid=false;
            
            for i=1:15
                ref=fullfile(FoldName,['Data_Test_',int2str(i),'_',app.Canal.Value,'.mat']);
                if exist(ref,'file')==2
                    valid=true; % il existe un fichier à comparer
                    k=i;
                end
            end
            
            if(valid==false)
                h=uifigure;
                tarea=uitextarea(h);
                tarea.Value='Action Impossible : Veuillez choisir une mesure existante comme référence'
            else
                ref=fullfile(FoldName,['Data_Test_',int2str(k),'_',app.Canal.Value,'.mat']);
                
                load(ref)
                
                Data1=Data2; %Data2 vient de ref
                
                ref2=fullfile(FoldName,['Markers_',int2str(k),'_',app.Canal.Value,'.mat']);
                
                load(ref2)
                
                Markers2=Markers;
                
                
                
                
                
                
                
                
                BData={'Identification sortie','Etat','Delta Gain Max (dB)','fréquence (MHz)','Delta Phase Max (°)','fréquence (MHz)','Delta Gain (dB)','Delta Phase (°)','Fréquence (MHz)'};
                
                
                
                figure(5) % Constitué d'une ligne et de deux colonnes
                
                
                
                subplot(1,2,1) % Premier graphique
                
                hold on
                
                clear title xlabel ylabel
                
                
                
                title('Gain=f(fréq)')
                
                xlabel('Fréquence (MHz)')
                
                ylabel ('Gain (dB)')
                
                
                subplot(1,2,2) % Deuxième graphique
                
                hold on
                
                clear title xlabel ylabel
                
                
                
                title('Phase=f(fréq)')
                
                xlabel('Fréquence (MHz)')
                
                ylabel ('Phase (°)')
                
                
                
                set(figure(5),'Units','Normalized','Outerposition',[0 0 1 1]);
                
                
                
                for i=1:10
                    for j=1:10
                        for l=1:2
                            go=false;
                            dossier=fullfile(app.Folder.Value,['Rack',int2str(i)],['Voie',int2str(j)],['Sortie',int2str(j),int2str(l)]);
                            
                            for m=1:15
                                if exist(fullfile(dossier,['Data_Test_',int2str(m),'_',app.Canal.Value,'.mat']),'file')==2
                                    n=m;
                                    go=true;
                                end
                            end
                            
                            
                            
                            if go==true
                                
                                
                                
                                acomp=fullfile(dossier,['Data_Test_',int2str(n),'_',app.Canal.Value,'.mat']);
                                
                                load(acomp)
                                
                                
                                acomp2=fullfile(dossier,['Markers_',int2str(n),'_',app.Canal.Value,'.mat']);
                                
                                load(acomp2)
                                
                                
                                etat='PASS';
                                
                                
                                
                                
                                
                                
                                
                                
                                if Data1(:,1)==Data2(:,1) % si les balayages de fréquence sont identiques
                                    
                                    %{
                                    
                                    carac=143.05;
                                    
                                    [pasbesoin, idx]=min(abs(Data1(:,1)-carac));
                                    
                                    freqCarac=Data1(idx,1);
                                    
                                    gainCarac=Data1(idx,2);
                                    
                                    gainDifCarac=Data2(idx,2)-Data1(idx,2);
                                    
                                    phaseCarac=Data2(idx,3)-Data1(idx,3);
                                    
                                    
                                    %}
                                    
                                    
                                    freqCarac=Markers{1};
                                    
                                    gainDifCarac=Markers{2}-Markers2{2};
                                    
                                    phaseCarac=Markers{3}-Markers2{3};
                                    
                                    
                                    DeltaMag=Data2(:,2)-Data1(:,2);
                                    
                                    DeltaMagMax=max(abs(DeltaMag));
                                    
                                    iDeltaMag=find(abs(DeltaMag)==max(abs(DeltaMag)));
                                    
                                    DeltaMagMax=Data2(iDeltaMag,2)-Data1(iDeltaMag,2)
                                    
                                    iDeltaMag=Data2(iDeltaMag,1);
                                    
                                    if app.DeltaGainMax.Value<DeltaMagMax
                                        etat='FAIL'
                                    end
                                    
                                    
                                    DeltaPhas=Data2(:,3)-Data1(:,3);
                                    
                                    DeltaPhasMax=max(abs(DeltaPhas));
                                    
                                    iDeltaPhas=find(abs(DeltaPhas)==max(abs(DeltaPhas)));
                                    
                                    DeltaPhasMax=Data2(iDeltaPhas,3)-Data1(iDeltaPhas,3)
                                    
                                    iDeltaPhas=Data2(iDeltaPhas,1);
                                    
                                    if app.DeltaPhasMax.Value<DeltaPhasMax
                                        etat='FAIL';
                                    end
                                    
                                    valeur={['Rack',int2str(i),'_Sortie',int2str(j),int2str(l)],etat,DeltaMagMax,iDeltaMag,DeltaPhasMax,iDeltaPhas,gainDifCarac,phaseCarac,freqCarac};
                                    BData=[BData;valeur];
                                    
                                    
                                    % GRAPH
                                    
                                    
                                    
                                    subplot(1,2,1) % Premier graphique
                                    
                                    plot(Data1(:,1), DeltaMag) % Gain en fonction de la fréquence
                                    
                                    
                                    subplot(1,2,2) % Deuxième graphique
                                    
                                    plot(Data1(:,1), DeltaPhas)
                                    
                                    
                                    
                                    
                                end
                            end
                        end
                    end
                end
                
                suptitle(['Comparaison des mesures ',app.Canal.Value,' - Référence : ',RackFolder,' ',SplitFolder,' ',PathFolder])
                
                
                saveas(figure(5),fullfile(app.Folder.Value,'Comparaison_Totale.png'));
                
                save(fullfile(app.Folder.Value,'Comparaison_Totale'),'BData');
                
                xlswrite(fullfile(app.Folder.Value,['Comparaison_Totale_',app.Canal.Value,'.xls']),BData);
                
            end
            
            
            
            
            
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 766 755];
            app.UIFigure.Name = 'UI Figure';

            % Create RUNButton
            app.RUNButton = uibutton(app.UIFigure, 'push');
            app.RUNButton.ButtonPushedFcn = createCallbackFcn(app, @RUNButtonPushed, true);
            app.RUNButton.BackgroundColor = [0.9294 0.6902 0.1294];
            app.RUNButton.FontSize = 18;
            app.RUNButton.FontWeight = 'bold';
            app.RUNButton.Position = [566 586 163 80];
            app.RUNButton.Text = 'RUN';

            % Create DbutMHzLabel
            app.DbutMHzLabel = uilabel(app.UIFigure);
            app.DbutMHzLabel.HorizontalAlignment = 'right';
            app.DbutMHzLabel.Position = [69 613 72 15];
            app.DbutMHzLabel.Text = 'Début [MHz]';

            % Create FreqStart
            app.FreqStart = uieditfield(app.UIFigure, 'numeric');
            app.FreqStart.LowerLimitInclusive = 'off';
            app.FreqStart.Limits = [0 100000];
            app.FreqStart.ValueDisplayFormat = '%5.2f';
            app.FreqStart.HorizontalAlignment = 'left';
            app.FreqStart.Position = [156 609 73 22];
            app.FreqStart.Value = 122;

            % Create FinMHzLabel
            app.FinMHzLabel = uilabel(app.UIFigure);
            app.FinMHzLabel.HorizontalAlignment = 'right';
            app.FinMHzLabel.Position = [85 579 56 15];
            app.FinMHzLabel.Text = 'Fin [MHz]';

            % Create FreqEnd
            app.FreqEnd = uieditfield(app.UIFigure, 'numeric');
            app.FreqEnd.LowerLimitInclusive = 'off';
            app.FreqEnd.Limits = [0 100000];
            app.FreqEnd.ValueDisplayFormat = '%5.2f';
            app.FreqEnd.HorizontalAlignment = 'left';
            app.FreqEnd.Position = [156 575 73 22];
            app.FreqEnd.Value = 142;

            % Create EmplacementdesauvegardeLabel
            app.EmplacementdesauvegardeLabel = uilabel(app.UIFigure);
            app.EmplacementdesauvegardeLabel.BackgroundColor = [0.8 0.8 0.8];
            app.EmplacementdesauvegardeLabel.HorizontalAlignment = 'right';
            app.EmplacementdesauvegardeLabel.FontSize = 14;
            app.EmplacementdesauvegardeLabel.Position = [20 200 192 18];
            app.EmplacementdesauvegardeLabel.Text = 'Emplacement de sauvegarde';

            % Create Folder
            app.Folder = uieditfield(app.UIFigure, 'text');
            app.Folder.FontSize = 14;
            app.Folder.Position = [223 198 513 22];
            app.Folder.Value = 'D:\labo\Desktop\Oscar\Mesure';

            % Create NombredepointsEditFieldLabel
            app.NombredepointsEditFieldLabel = uilabel(app.UIFigure);
            app.NombredepointsEditFieldLabel.HorizontalAlignment = 'right';
            app.NombredepointsEditFieldLabel.Position = [39 545 102 19];
            app.NombredepointsEditFieldLabel.Text = 'Nombre de points';

            % Create NbPoints
            app.NbPoints = uieditfield(app.UIFigure, 'numeric');
            app.NbPoints.LowerLimitInclusive = 'off';
            app.NbPoints.Limits = [0 1000];
            app.NbPoints.ValueDisplayFormat = '%.0f';
            app.NbPoints.HorizontalAlignment = 'left';
            app.NbPoints.Position = [157 543 72 22];
            app.NbPoints.Value = 200;

            % Create BandedefrquenceLabel
            app.BandedefrquenceLabel = uilabel(app.UIFigure);
            app.BandedefrquenceLabel.BackgroundColor = [0.8 0.8 0.8];
            app.BandedefrquenceLabel.FontSize = 14;
            app.BandedefrquenceLabel.Position = [89 648 134 18];
            app.BandedefrquenceLabel.Text = 'Bande de fréquence';

            % Create ChoixmesureLabel
            app.ChoixmesureLabel = uilabel(app.UIFigure);
            app.ChoixmesureLabel.BackgroundColor = [0.8 0.8 0.8];
            app.ChoixmesureLabel.HorizontalAlignment = 'right';
            app.ChoixmesureLabel.FontSize = 14;
            app.ChoixmesureLabel.Position = [306 646 93 18];
            app.ChoixmesureLabel.Text = 'Choix mesure';

            % Create Canal
            app.Canal = uilistbox(app.UIFigure);
            app.Canal.Items = {'S11', 'S12', 'S22', 'S21'};
            app.Canal.Position = [414 592 100 74];
            app.Canal.Value = 'S21';

            % Create NumroderackSpinnerLabel
            app.NumroderackSpinnerLabel = uilabel(app.UIFigure);
            app.NumroderackSpinnerLabel.HorizontalAlignment = 'right';
            app.NumroderackSpinnerLabel.Position = [307 413 92 15];
            app.NumroderackSpinnerLabel.Text = 'Numéro de rack';

            % Create NumRack
            app.NumRack = uispinner(app.UIFigure);
            app.NumRack.Limits = [1 10];
            app.NumRack.ValueDisplayFormat = '%.0f';
            app.NumRack.Position = [414 409 100 22];
            app.NumRack.Value = 1;

            % Create NumrodevoieLabel
            app.NumrodevoieLabel = uilabel(app.UIFigure);
            app.NumrodevoieLabel.HorizontalAlignment = 'right';
            app.NumrodevoieLabel.Position = [307 378 92 15];
            app.NumrodevoieLabel.Text = 'Numéro de voie';

            % Create NumSplit
            app.NumSplit = uispinner(app.UIFigure);
            app.NumSplit.Limits = [1 10];
            app.NumSplit.ValueDisplayFormat = '%.0f';
            app.NumSplit.Position = [414 374 100 22];
            app.NumSplit.Value = 1;

            % Create NumrodesortieSpinnerLabel
            app.NumrodesortieSpinnerLabel = uilabel(app.UIFigure);
            app.NumrodesortieSpinnerLabel.HorizontalAlignment = 'right';
            app.NumrodesortieSpinnerLabel.Position = [300 342 99 15];
            app.NumrodesortieSpinnerLabel.Text = 'Numéro de sortie';

            % Create NumPath
            app.NumPath = uispinner(app.UIFigure);
            app.NumPath.Limits = [1 2];
            app.NumPath.ValueDisplayFormat = '%.0f';
            app.NumPath.Position = [414 338 100 22];
            app.NumPath.Value = 1;

            % Create Avertis
            app.Avertis = uicheckbox(app.UIFigure);
            app.Avertis.Text = 'Avertissement';
            app.Avertis.FontSize = 14;
            app.Avertis.Position = [593 535 111.75 18];

            % Create IdentitappareilTextAreaLabel
            app.IdentitappareilTextAreaLabel = uilabel(app.UIFigure);
            app.IdentitappareilTextAreaLabel.BackgroundColor = [0.8 0.8 0.8];
            app.IdentitappareilTextAreaLabel.HorizontalAlignment = 'right';
            app.IdentitappareilTextAreaLabel.FontSize = 14;
            app.IdentitappareilTextAreaLabel.Position = [105 161 107 18];
            app.IdentitappareilTextAreaLabel.Text = 'Identité appareil';

            % Create Identite
            app.Identite = uitextarea(app.UIFigure);
            app.Identite.Editable = 'off';
            app.Identite.Position = [223 160 513 20];

            % Create GainmaxdBEditFieldLabel
            app.GainmaxdBEditFieldLabel = uilabel(app.UIFigure);
            app.GainmaxdBEditFieldLabel.HorizontalAlignment = 'right';
            app.GainmaxdBEditFieldLabel.Position = [65 423 81 15];
            app.GainmaxdBEditFieldLabel.Text = 'Gain max [dB]';

            % Create GainMax
            app.GainMax = uieditfield(app.UIFigure, 'numeric');
            app.GainMax.Position = [161 419 70 22];
            app.GainMax.Value = 3;

            % Create GainmindBEditFieldLabel
            app.GainmindBEditFieldLabel = uilabel(app.UIFigure);
            app.GainmindBEditFieldLabel.HorizontalAlignment = 'right';
            app.GainmindBEditFieldLabel.Position = [68 393 78 15];
            app.GainmindBEditFieldLabel.Text = 'Gain min [dB]';

            % Create GainMin
            app.GainMin = uieditfield(app.UIFigure, 'numeric');
            app.GainMin.Position = [161 389 70 22];
            app.GainMin.Value = 1.5;

            % Create DphasagemaxEditFieldLabel
            app.DphasagemaxEditFieldLabel = uilabel(app.UIFigure);
            app.DphasagemaxEditFieldLabel.HorizontalAlignment = 'right';
            app.DphasagemaxEditFieldLabel.Position = [37 353 109 15];
            app.DphasagemaxEditFieldLabel.Text = 'Déphasage max [°]';

            % Create DephasMax
            app.DephasMax = uieditfield(app.UIFigure, 'numeric');
            app.DephasMax.Position = [161 349 70 22];
            app.DephasMax.Value = -3;

            % Create DphasageminEditFieldLabel
            app.DphasageminEditFieldLabel = uilabel(app.UIFigure);
            app.DphasageminEditFieldLabel.HorizontalAlignment = 'right';
            app.DphasageminEditFieldLabel.Position = [40 323 106 15];
            app.DphasageminEditFieldLabel.Text = 'Déphasage min [°]';

            % Create DephasMin
            app.DephasMin = uieditfield(app.UIFigure, 'numeric');
            app.DephasMin.Position = [161 319 70 22];
            app.DephasMin.Value = -41;

            % Create CorrespondanceDuplicateurLabel
            app.CorrespondanceDuplicateurLabel = uilabel(app.UIFigure);
            app.CorrespondanceDuplicateurLabel.BackgroundColor = [0.8 0.8 0.8];
            app.CorrespondanceDuplicateurLabel.FontSize = 14;
            app.CorrespondanceDuplicateurLabel.Position = [317 453 187 18];
            app.CorrespondanceDuplicateurLabel.Text = 'Correspondance Duplicateur';

            % Create LimitesautorisesLabel
            app.LimitesautorisesLabel = uilabel(app.UIFigure);
            app.LimitesautorisesLabel.BackgroundColor = [0.8 0.8 0.8];
            app.LimitesautorisesLabel.FontSize = 14;
            app.LimitesautorisesLabel.Position = [91 453 120 18];
            app.LimitesautorisesLabel.Text = 'Limites autorisées';

            % Create ApplicationdemesuresLabel
            app.ApplicationdemesuresLabel = uilabel(app.UIFigure);
            app.ApplicationdemesuresLabel.HorizontalAlignment = 'center';
            app.ApplicationdemesuresLabel.VerticalAlignment = 'center';
            app.ApplicationdemesuresLabel.FontSize = 18;
            app.ApplicationdemesuresLabel.FontWeight = 'bold';
            app.ApplicationdemesuresLabel.Position = [275.5 719 210 23];
            app.ApplicationdemesuresLabel.Text = 'Application de mesures';

            % Create ListederreursTextAreaLabel
            app.ListederreursTextAreaLabel = uilabel(app.UIFigure);
            app.ListederreursTextAreaLabel.BackgroundColor = [0.8 0.8 0.8];
            app.ListederreursTextAreaLabel.HorizontalAlignment = 'right';
            app.ListederreursTextAreaLabel.FontSize = 14;
            app.ListederreursTextAreaLabel.Position = [114 55 96 18];
            app.ListederreursTextAreaLabel.Text = 'Liste d''erreurs';

            % Create Errors
            app.Errors = uitextarea(app.UIFigure);
            app.Errors.Editable = 'off';
            app.Errors.FontSize = 14;
            app.Errors.Position = [225 39 511 50];

            % Create DeltaGainmaxdBEditFieldLabel
            app.DeltaGainmaxdBEditFieldLabel = uilabel(app.UIFigure);
            app.DeltaGainmaxdBEditFieldLabel.HorizontalAlignment = 'right';
            app.DeltaGainmaxdBEditFieldLabel.Position = [34 287 113 15];
            app.DeltaGainmaxdBEditFieldLabel.Text = 'Delta Gain max [dB]';

            % Create DeltaGainMax
            app.DeltaGainMax = uieditfield(app.UIFigure, 'numeric');
            app.DeltaGainMax.Position = [161 283 70 22];
            app.DeltaGainMax.Value = 0.5;

            % Create DeltaDphasagemaxEditFieldLabel
            app.DeltaDphasagemaxEditFieldLabel = uilabel(app.UIFigure);
            app.DeltaDphasagemaxEditFieldLabel.HorizontalAlignment = 'right';
            app.DeltaDphasagemaxEditFieldLabel.Position = [13 257 141 15];
            app.DeltaDphasagemaxEditFieldLabel.Text = 'Delta Déphasage max [°]';

            % Create DeltaPhasMax
            app.DeltaPhasMax = uieditfield(app.UIFigure, 'numeric');
            app.DeltaPhasMax.Position = [161 253 70 22];
            app.DeltaPhasMax.Value = 0.5;

            % Create AdresseTextAreaLabel
            app.AdresseTextAreaLabel = uilabel(app.UIFigure);
            app.AdresseTextAreaLabel.BackgroundColor = [0.8 0.8 0.8];
            app.AdresseTextAreaLabel.HorizontalAlignment = 'right';
            app.AdresseTextAreaLabel.FontSize = 14;
            app.AdresseTextAreaLabel.Position = [151 121 57 18];
            app.AdresseTextAreaLabel.Text = 'Adresse';

            % Create Adresse
            app.Adresse = uitextarea(app.UIFigure);
            app.Adresse.Editable = 'off';
            app.Adresse.Position = [223 119 513 22];

            % Create RESETButton
            app.RESETButton = uibutton(app.UIFigure, 'push');
            app.RESETButton.ButtonPushedFcn = createCallbackFcn(app, @RESETButtonPushed, true);
            app.RESETButton.BackgroundColor = [0.851 0.3294 0.102];
            app.RESETButton.FontSize = 14;
            app.RESETButton.FontColor = [1 1 1];
            app.RESETButton.Position = [599 271 100 25];
            app.RESETButton.Text = 'RESET';

            % Create TOUTCOMPARERButton
            app.TOUTCOMPARERButton = uibutton(app.UIFigure, 'push');
            app.TOUTCOMPARERButton.ButtonPushedFcn = createCallbackFcn(app, @TOUTCOMPARERButtonPushed, true);
            app.TOUTCOMPARERButton.BackgroundColor = [0.302 0.749 0.9294];
            app.TOUTCOMPARERButton.FontSize = 14;
            app.TOUTCOMPARERButton.FontColor = [1 1 1];
            app.TOUTCOMPARERButton.Position = [353.5 271 137 25];
            app.TOUTCOMPARERButton.Text = 'TOUT COMPARER';

            % Create PositionMarkerMHzEditFieldLabel
            app.PositionMarkerMHzEditFieldLabel = uilabel(app.UIFigure);
            app.PositionMarkerMHzEditFieldLabel.HorizontalAlignment = 'right';
            app.PositionMarkerMHzEditFieldLabel.Position = [17 514 124 15];
            app.PositionMarkerMHzEditFieldLabel.Text = 'Position Marker [MHz]';

            % Create Marker
            app.Marker = uieditfield(app.UIFigure, 'numeric');
            app.Marker.Limits = [0 Inf];
            app.Marker.ValueDisplayFormat = '%5.2f';
            app.Marker.HorizontalAlignment = 'left';
            app.Marker.Position = [157 510 72 22];
            app.Marker.Value = 132;

            % Create NombrecyclemoyennageEditFieldLabel
            app.NombrecyclemoyennageEditFieldLabel = uilabel(app.UIFigure);
            app.NombrecyclemoyennageEditFieldLabel.BackgroundColor = [0.8 0.8 0.8];
            app.NombrecyclemoyennageEditFieldLabel.VerticalAlignment = 'center';
            app.NombrecyclemoyennageEditFieldLabel.FontSize = 14;
            app.NombrecyclemoyennageEditFieldLabel.Position = [329 539 171 18];
            app.NombrecyclemoyennageEditFieldLabel.Text = 'Nombre cycle moyennage';

            % Create balayage
            app.balayage = uieditfield(app.UIFigure, 'numeric');
            app.balayage.Limits = [1 200];
            app.balayage.HorizontalAlignment = 'center';
            app.balayage.Position = [381 510 66 22];
            app.balayage.Value = 20;
        end
    end

    methods (Access = public)

        % Construct app
        function app = HF_FieldFox_v2

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
