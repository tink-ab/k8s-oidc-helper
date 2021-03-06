# k8s-oidc-helper

This is a small helper tool to get a user get authenticated with
[Kubernetes OIDC](http://kubernetes.io/docs/admin/authentication/) using any OpenID Connect Provider
as the Identity Provider.

Given a ClientID, ClientSecret and Issuer URL, the tool will output the necessary
configuration for `kubectl` that you can add to `~/.kube/config`.

```bash
$ k8s-oidc-helper -c ./client_secret.json
Enter the code Google gave you: <code>

# Add the following to your ~/.kube/config
users:
- name: you@yourdomain.com
  user:
    auth-provider:
      config:
        client-id: <client-id>
        client-secret: <client-secret>
        id-token: <id-token>
        idp-issuer-url: https://accounts.google.com
        refresh-token: <refresh-token>
      name: oidc
```

To merge the new configuration into your existing kubectl config file, run:

```bash
$ k8s-oidc-helper -c ./client_secret.json --write
Enter the code Google gave you: <code>

Configuration has been written to ~/.kube/config

# Then you can associate that user to a cluster
$ kubectl config set-context <context-name> --cluster <cluster-name> --user <you@yourdomain.com>
$ kubectl config use-context <context-name>
```

## Setup

There is a bit of setup involved before you can use this tool.

### Google OAuth Setup

First, you'll need to create a project and OAuth 2.0 Credential in the Google
Cloud Console. You can follow [this guide](https://developers.google.com/identity/sign-in/web/devconsole-project)
on creating an application, but do *NOT* create a web application. You'll need
to select "Other" as the Application Type. Once that is created, you can
download the ClientID and ClientSecret as a JSON file for ease of use.

### Other OAuth providers

Setting up this project with other OAuth providers should similar to the Google setup guide above.

### kube-apiserver Setup

Second, your kube-apiserver will need the following flags on to use OpenID Connect.

```
--oidc-issuer-url=https://accounts.google.com \
--oidc-username-claim=email \
--oidc-client-id=<Your client ID> \
```

### Role-Based Access Control

If you are using [RBAC](http://kubernetes.io/docs/admin/authorization/) as your
`--authorization-mode`, you can use the following `ClusterRole` and
`ClusterRoleBinding` for administrators that need cluster-wide access.

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1alpha1
metadata:
  name: admin-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
  nonResourceURLs: ["*"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1alpha1
metadata:
  name: admin-binding
subjects:
- kind: User
  name: you@yourdomain.com
roleRef:
  kind: ClusterRole
  name: admin-role
```

## Installation

```bash
go get github.com/tink-ab/k8s-oidc-helper
dep ensure
```

## Usage

```
Usage of k8s-oidc-helper:
      --client-id string       The ClientID for the application
      --client-secret string   The ClientSecret for the application
  -c, --config string          Path to a json file containing your Google application's ClientID and ClientSecret. Supercedes the --client-id and --client-secret flags.
      --file ~/.kube/config    The file to write to. If not specified, ~/.kube/config is used
      --issuer-url string      OIDC Discovery URL, such that <URL>/.well-known/openid-configuration can be fetched
  -o, --open                   Open the oauth approval URL in the browser (default true)
      --redirect-uri string    URI to redirect to. Set to urn:ietf:wg:oauth:2.0:oob to use in-browser copy-paste method. (default "http://localhost")
      --scopes string          Required scopes to be passed to the Authicator. offline_access is added if access_type parameter is not supported by authorizer (default "openid email")
      --user-claim string      The Claim in ID-Token used to identify the user. One of sub/email/name (default "email")
  -v, --version                Print version and exit
  -w, --write                  Write config to file. Merges in the specified file
```

## License

MIT License. See [License](/LICENSE) for full text
