{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Core Kubernetes tools
    kubectl
    kubernetes-helm
    helmfile
    kustomize

    # Kubernetes context/namespace management
    kubie
    kubectx # provides kubectx and kubens

    # Logging and debugging
    stern
    k9s
    kubectl-tree
    kubectl-neat

    # Container tools
    podman
    podman-compose
    dive # analyze docker images
    skopeo # work with container registries

    # Additional K8s utilities
    kubeconform # validate kubernetes manifests
    kube-linter # lint kubernetes manifests
    kubectl-view-allocations

    # Colored kubectl output
    kubecolor
  ];

  # K9s configuration
  xdg.configFile."k9s/config.yaml".text = ''
    k9s:
      liveViewAutoRefresh: true
      refreshRate: 2
      maxConnRetry: 5
      readOnly: false
      noExitOnCtrlC: false
      ui:
        enableMouse: true
        headless: false
        logoless: false
        crumbsless: false
        reactive: true
        noIcons: false
        defaultsToFullScreen: false
      skipLatestRevCheck: false
      disablePodCounting: false
      shellPod:
        image: busybox:1.35.0
        namespace: default
        limits:
          cpu: 100m
          memory: 100Mi
      imageScans:
        enable: false
      logger:
        tail: 100
        buffer: 5000
        sinceSeconds: -1
        fullScreen: false
        textWrap: false
        showTime: false
      thresholds:
        cpu:
          critical: 90
          warn: 70
        memory:
          critical: 90
          warn: 70
  '';

  # Kubie configuration (must be at ~/.kube/kubie.yaml)
  home.file.".kube/kubie.yaml".text = ''
    prompt:
      disable: true  # Using starship for k8s context display instead
    behavior:
      validate_namespaces: true
    configs:
      include:
        - ~/.kube/config
        - ~/.kube/configs/*
  '';
}
